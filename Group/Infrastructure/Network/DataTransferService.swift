//
//  DataTransferService.swift
//  Group
//
//  Created by CatSlave on 8/19/24.
//

import Foundation
import RxSwift

enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void

    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E
    ) -> Single<T> where E.Response == T

    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E
    ) -> Single<Void> where E.Response == Void
}

protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

protocol DataTransferErrorLogger {
    func log(error: Error)
}

final class DefaultDataTransferService {
    
    // config, session, error를 처리한 서비스
    private let networkService: NetworkService
    
    private let errorResolver: DataTransferErrorResolver
    
    private let errorLogger: DataTransferErrorLogger
    
    init(
        with networkService: NetworkService,
        errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver(),
        errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger()
    ) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
}

extension DefaultDataTransferService: DataTransferService {

    func request<T: Decodable, E: ResponseRequestable>(with endpoint: E) -> Single<T> where E.Response == T {
        
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(DataTransferError.noResponse))
                return Disposables.create()
            }

            let task = networkService.request(endpoint: endpoint)
                .subscribe(with: self, onSuccess: { service, data in
                    let result: Result<T, DataTransferError> = service.decode(data: data,
                                                                              decoder: endpoint.responseDecoder)
                    
                    switch result {
                    case .success(let value):
                        single(.success(value))
                    case .failure(let err):
                        single(.failure(err))
                    }
                    
                }, onFailure: { service, err in
                    single(.failure(err))
                })
            
            return task
        }
    }

    func request<E>(with endpoint: E) -> Single<Void> where E : ResponseRequestable, E.Response == Void {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(DataTransferError.noResponse))
                return Disposables.create()
            }
            
            let task = networkService.request(endpoint: endpoint)
                .subscribe(with: self, onSuccess: { service, event in
                    single(.success(()))
                }, onFailure: { service, err in
                    single(.failure(err))
                })
            
            return task
        }
    }
        
    // MARK: - Private
    private func decode<T: Decodable>(
        data: Data?,
        decoder: ResponseDecoder
    ) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
    
    // decode 과정 중 예상치 못한 에러가 발생할 수 있기에 기본 error 타입을 처리
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError
        ? .networkFailure(error)
        : .resolvedNetworkFailure(resolvedError)
    }
}

// MARK: - Logger
final class DefaultDataTransferErrorLogger: DataTransferErrorLogger {
    init() { }
    
    func log(error: Error) {
        printIfDebug("-------------")
        printIfDebug("\(error)")
    }
}

// MARK: - Error Resolver
class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    init() { }
    func resolve(error: NetworkError) -> Error {
        return error
    }
}

// MARK: - Response Decoders
class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    init() { }
    func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

class RawDataResponseDecoder: ResponseDecoder {
    init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.default],
                debugDescription: "Expected Data type"
            )
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}




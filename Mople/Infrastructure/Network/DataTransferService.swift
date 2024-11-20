//
//  DataTransferService.swift
//  Group
//
//  Created by CatSlave on 8/19/24.
//

import Foundation
import RxSwift

enum ServerError: Error {
    case httpRespon(statusCode: Int)
    case errRespon(message: String?)
}

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
    
    private func performBaseRequest<E: ResponseRequestable, T>(
        endpoint: E,
        transform: @escaping (Data?) -> Single<T>
    ) -> Single<T> {
        return Single.create { single in
            let task = self.networkService.request(endpoint: endpoint)
                .flatMap(transform)
                .subscribe(onSuccess: { response in
                    single(.success(response))
                }, onFailure: { err in
                    self.errorLogger.log(error: err)
                    if let err = err as? NetworkError {
                        let transferError = self.resolve(networkError: err)
                        single(.failure(transferError))
                    } else {
                        single(.failure(err))
                    }
                })
            return task
        }
    }

    /// 리턴값이 있는 요청
    func request<E: ResponseRequestable>(
        with endpoint: E
    ) -> Single<E.Response> where E.Response: Decodable {
        return performBaseRequest(endpoint: endpoint) { data in
            self.decode(data: data, decoder: endpoint.responseDecoder)
        }
    }

    /// 응답만 있는 요청
    func request<E: ResponseRequestable>(
        with endpoint: E
    ) -> Single<Void> where E.Response == Void {
        return performBaseRequest(endpoint: endpoint) { _ in
            .just(())
        }
    }
    
    // MARK: - Private
    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Single<T> {
        return Single.create(subscribe: { emitter in
            guard let data = data else {
                emitter(.failure(DataTransferError.noResponse))
                return Disposables.create()
            }
            
            do {
                let result: T = try decoder.decode(data)
                emitter(.success(result))
            } catch {
                self.errorLogger.log(error: error)
                emitter(.failure(DataTransferError.parsing(error)))
            }
            
            return Disposables.create()
        })
    }
    
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
        switch error {
        case .error(let statusCode, _):
            return ServerError.httpRespon(statusCode: statusCode)
        case .responseError(let err):
            return ServerError.errRespon(message: err?.message)
        @unknown default:
            return error
        }
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







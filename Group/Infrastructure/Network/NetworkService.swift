//
//  NetworkService.swift
//  Group
//
//  Created by CatSlave on 8/19/24.
//

import Foundation
import RxSwift
import RxRelay

enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case unknownError(Error?)
    case urlGeneration
    case responseError(err: ErrorResponse?)
}

protocol NetworkService {
    func request(endpoint: Requestable) -> Single<Data?>
}

protocol NetworkSessionManager {
    typealias SessionResult = Single<(data: Data?,response: URLResponse?,error: Error?)>
    
    func request(_ request: URLRequest) -> SessionResult
}

protocol NetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?)
    func log(error: Error)
}

// MARK: - Implementation

final class DefaultNetworkService {
    
    // MARK: - NetworkService 기본 구성요소

    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    private let logger: NetworkErrorLogger
    
    init(
        config: NetworkConfigurable,
        sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
        logger: NetworkErrorLogger = DefaultNetworkErrorLogger()
    ) {
        self.sessionManager = sessionManager
        self.config = config
        self.logger = logger
    }
    
    private func request(request: URLRequest) -> Single<Data?> {
        
        return Single.create { single in
            
            self.logger.log(request: request)
            
            let task = self.sessionManager.request(request)
                .subscribe(onSuccess: { value in
                    if let err = value.error {
                        var error: NetworkError
                        
                        if let response = value.response as? HTTPURLResponse {
                            error = .error(statusCode: response.statusCode, data: value.data)
                        } else {
                            error = self.resolve(error: err)
                        }
                        
                        self.logger.log(error: error)
                        single(.failure(error))
                        return
                    }
                    
                    self.logger.log(responseData: value.data)
                    
                    guard let httpResponse = value.response as? HTTPURLResponse else {
                        single(.failure(NetworkError.unknownError(nil)))
                        return
                    }
                    
                    switch httpResponse.statusCode {
                    case 400:
                        guard let data = value.data,
                              let responseError = try? JSONDecoder().decode(ErrorResponse.self, from: data) else {
                            single(.failure(NetworkError.responseError(err: nil)))
                            return
                        }
                        single(.failure(NetworkError.responseError(err: responseError)))
                        return
                    default:
                        single(.success(value.data))
                    }
                })
            
            return task
        }
    }
    
    // 응답값이 없는 경우 Error -> NetworkError 변환 후 return
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        default: return .unknownError(error)
        }
    }
}

extension DefaultNetworkService: NetworkService {

    // URLRequest 생성
    func request(endpoint: Requestable) -> Single<Data?> {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest)
        } catch {
            return Single.error(NetworkError.urlGeneration)
        }
    }
}

// MARK: - Default Network Session Manager
final class DefaultNetworkSessionManager: NetworkSessionManager {
    
    // URLSession 생성
    func request(_ request: URLRequest) -> SessionResult {
        return Single.create { single in
            
            let task = URLSession.shared.dataTask(with: request) { data, response, err in
                single(.success((data, response, err)))
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

// MARK: - Logger
final class DefaultNetworkErrorLogger: NetworkErrorLogger {
    init() { }

    func log(request: URLRequest) {
        print("-------------")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields!)")
        print("method: \(request.httpMethod!)")
        
        guard let httpBody = request.httpBody else {
            printIfDebug("body: no data")
            return
        }
                
        if let jsonObject = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject] {
            printIfDebug("body: \(jsonObject)")
        } else if let bodyString = String(data: httpBody, encoding: .utf8) {
            printIfDebug("body: \(bodyString)")
        } else {
            printIfDebug("body: Unable to parse")
        }
    }

    func log(responseData data: Data?) {
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            printIfDebug("responseData: \(String(describing: dataDict))")
        }
    }

    func log(error: Error) {
        printIfDebug("\(error)")
    }
}

// MARK: - NetworkError extension

func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}

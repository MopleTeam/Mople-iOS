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
    case notConnected
    case unknownError(Error?)
    case urlGeneration
    case error(statusCode: Int, data: Data)
}

protocol NetworkService {
    func request(endpoint: Requestable) -> Single<Data?>
}

protocol NetworkSessionManager {
    
    func request(_ request: URLRequest) -> Single<(response: HTTPURLResponse, data: Data)>
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
        self.logger.log(request: request)
        return self.sessionManager.request(request)
            .map { value in
                let statusCode = value.response.statusCode
                let data = value.data
                switch statusCode {
                case 200...299:
                    return data
                default:
                    throw NetworkError.error(statusCode: statusCode, data: data)
                }
            }
            .catch { error in
                throw self.resolve(error: error)
            }
    }
    
    // 응답값이 없는 경우 Error -> NetworkError 변환 후 return
    private func resolve(error: Error) -> NetworkError {
        switch error {
        case let NetworkError.error(statusCode, data):
            return .error(statusCode: statusCode, data: data)
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet:
                return .notConnected
            default:
                return .unknownError(error)
            }
        default:
            return .unknownError(error)
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
    func request(_ request: URLRequest) -> Single<(response: HTTPURLResponse, data: Data)> {
        URLSession.shared.rx.response(request: request)
            .map({ response, data in
                return (response, data)
            })
            .asSingle()
    }
}

// MARK: - Logger

#warning("실제 출시에는 제거 및 다른 Logger 시스템을 채택해야함 (개인정보 침해)")
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

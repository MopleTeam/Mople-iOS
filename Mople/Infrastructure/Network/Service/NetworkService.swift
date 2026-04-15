//
//  NetworkService.swift
//  Mople
//
//  Created by CatSlave on 8/19/24.
//  Refactored: RxSwift → async/await (Phase 3)
//

import Foundation
import Domain
import Data

// NetworkError / NetworkService / NetworkSessionManager / NetworkErrorLogger 프로토콜 정의는
// Data 모듈로 이전됨

// MARK: - NetworkService 구현
final class DefaultNetworkService {

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

    // URLRequest → 서버 호출 → 상태코드 검사 → Data 반환
    private func request(request: URLRequest) async throws -> Data? {
        logger.log(request: request)

        do {
            let result = try await sessionManager.request(request)
            let statusCode = result.response.statusCode
            let data = result.data

            switch statusCode {
            case 200...299:
                return data
            default:
                throw NetworkError.error(statusCode: statusCode, data: data)
            }
        } catch {
            throw resolve(error: error)
        }
    }

    // Error → NetworkError 변환
    private func resolve(error: Error) -> NetworkError {
        switch error {
        case let NetworkError.error(statusCode, data):
            return .error(statusCode: statusCode, data: data)
        case let urlError as URLError:
            switch urlError.code {
            case .cannotConnectToHost:
                return .notConnectedServer
            case .notConnectedToInternet:
                return .notConnectedInternet
            default:
                return .unknownError(error)
            }
        default:
            return .unknownError(error)
        }
    }
}

extension DefaultNetworkService: NetworkService {
    // Endpoint → URLRequest 생성 → 요청
    func request(endpoint: Requestable) async throws -> Data? {
        let urlRequest = try endpoint.urlRequest(with: config)
        return try await request(request: urlRequest)
    }
}

// MARK: - URLSession 래퍼 (async/await 네이티브)
// Before: URLSession.shared.rx.response(request:).asSingle().timeout(...)
// After:  URLSession.shared.data(for:) + 타임아웃 설정
final class DefaultNetworkSessionManager: NetworkSessionManager {
    func request(_ request: URLRequest) async throws -> (response: HTTPURLResponse, data: Data) {
        var timedRequest = request
        timedRequest.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: timedRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.notConnectedServer
        }
        return (httpResponse, data)
    }
}

// MARK: - Logger (변경 없음)
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

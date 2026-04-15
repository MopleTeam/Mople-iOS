//
//  NetworkService.swift
//  Data
//
//  URLSession 기반 네트워크 요청 프로토콜
//  구현체(DefaultNetworkService)는 App 타겟에 위치
//

import Foundation

// MARK: - 프로토콜 정의
public protocol NetworkService {
    func request(endpoint: Requestable) async throws -> Data?
}

public protocol NetworkSessionManager {
    func request(_ request: URLRequest) async throws -> (response: HTTPURLResponse, data: Data)
}

public protocol NetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?)
    func log(error: Error)
}

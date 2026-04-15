//
//  AppNetworkService.swift
//  Data
//
//  Repository가 네트워크 요청을 수행하기 위한 프로토콜
//  구현체(DefaultAppNetWorkService)는 App 타겟에 위치
//

import Foundation

// MARK: - 프로토콜 정의
public protocol AppNetworkService {
    func basicRequest<T: Decodable, E: ResponseRequestable>(
        endpoint: E
    ) async throws -> T where E.Response == T

    func authenticatedRequest<T: Decodable, E: ResponseRequestable>(
        endpointClosure: @escaping () throws -> E
    ) async throws -> E.Response where E.Response == T

    func authenticatedRequest<E: ResponseRequestable>(
        endpointClosure: @escaping () throws -> E
    ) async throws where E.Response == Void
}

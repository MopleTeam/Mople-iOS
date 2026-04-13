//
//  AppNetworkService.swift
//  Mople
//
//  Created by CatSlave on 8/22/24.
//  Refactored: RxSwift → async/await (Phase 3)
//

import Foundation
import Domain

// MARK: - 프로토콜 정의
// Before: func authenticatedRequest(...) -> Single<T>
// After:  func authenticatedRequest(...) async throws -> T
protocol AppNetworkService {
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

// MARK: - 구현체
final class DefaultAppNetWorkService: AppNetworkService {

    private let errorHandlingService = DefaultErrorHandlingService()
    private let dataTransferService: DataTransferService

    // 토큰 재발급 동시 요청 방지 (Rx의 share(replay:1) 대체)
    private var ongoingRefreshTask: Task<Void, Error>?

    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }

    // MARK: - 기본 요청 (토큰 불필요)

    /// 응답 값이 있는 요청
    func basicRequest<E: ResponseRequestable>(
        endpoint: E
    ) async throws -> E.Response where E.Response: Decodable {
        do {
            return try await dataTransferService.request(with: endpoint)
        } catch {
            throw handleDataTransferError(error)
        }
    }

    /// 응답 값이 없는 요청
    func basicRequest<E: ResponseRequestable>(
        endpoint: E
    ) async throws where E.Response == Void {
        do {
            try await dataTransferService.request(with: endpoint)
        } catch {
            throw handleDataTransferError(error)
        }
    }

    // MARK: - 인증 요청 (토큰 필요 + 만료 시 자동 재발급)

    /// 응답 값이 있는 인증 요청
    func authenticatedRequest<E: ResponseRequestable>(
        endpointClosure: @escaping () throws -> E
    ) async throws -> E.Response where E.Response: Decodable {
        return try await retryWithToken {
            let endpoint = try endpointClosure()
            return try await self.basicRequest(endpoint: endpoint)
        }
    }

    /// 응답 값이 없는 인증 요청
    func authenticatedRequest<E: ResponseRequestable>(
        endpointClosure: @escaping () throws -> E
    ) async throws where E.Response == Void {
        try await retryWithToken {
            let endpoint = try endpointClosure()
            try await self.basicRequest(endpoint: endpoint)
        }
    }

    // MARK: - 토큰 재발급 + 재시도 로직
    // Before: Rx retry + flatMap + share(replay:1)
    // After:  단순 do-catch + Task 공유

    /// 요청 실행 → 토큰 만료 시 재발급 후 1회 재시도
    private func retryWithToken<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch let error as DataRequestError where error == .expiredToken {
            // 토큰 만료 → 재발급 → 재시도
            try await reissueTokenIfNeeded()
            return try await operation()
        }
    }

    /// 동시에 여러 요청이 토큰 만료를 만나도 재발급은 1번만 실행
    /// Before: ongoingRefresh Observable + share(replay:1)
    /// After:  ongoingRefreshTask 공유
    private func reissueTokenIfNeeded() async throws {
        // 이미 재발급 중이면 기존 Task 대기
        if let ongoingRefreshTask {
            try await ongoingRefreshTask.value
            return
        }

        let task = Task {
            defer { ongoingRefreshTask = nil }
            do {
                let refreshEndpoint = try APIEndpoints.reissueToken()
                let tokenData: Data = try await dataTransferService.request(with: refreshEndpoint)
                KeychainStorage.shared.saveToken(tokenData)
            } catch {
                await MainActor.run {
                    errorHandlingService.handleError(.expiredToken)
                }
                throw DataRequestError.handled
            }
        }

        ongoingRefreshTask = task
        try await task.value
    }

    // MARK: - 에러 변환

    private func handleDataTransferError(_ error: Error) -> DataRequestError {
        guard let transferError = error as? DataTransferError else {
            return DataRequestError.unknown
        }
        return resolveDataTransferError(err: transferError)
    }

    private func resolveDataTransferError(err: DataTransferError) -> DataRequestError {
        switch err {
        case let .networkFailure(networkErr):
            switch networkErr {
            case .notConnectedInternet:
                errorHandlingService.handleError(.networkUnavailable)
            default:
                errorHandlingService.handleError(.serverUnavailable)
            }
            return .handled
        case .expiredToken:
            return .expiredToken
        case .noResponse:
            return .noResponse
        default:
            errorHandlingService.handleError(.unknown)
            return .handled
        }
    }
}

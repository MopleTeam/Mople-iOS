//
//  DefaultGroupRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import Foundation
import RxSwift
import RxRelay

protocol AppNetworkService {
    func basicRequest<T: Decodable, E: ResponseRequestable>(endpoint: E) -> Single<T> where E.Response == T
    
    func authenticatedRequest<T: Decodable, E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<E.Response> where E.Response == T
    
    func authenticatedRequest<E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<Void> where E.Response == Void
}

final class DefaultAppNetWorkService: AppNetworkService {
   
    private var ongoingRefresh: Observable<Void>? = nil
    private let errorHandlingService = DefaultErrorHandlingService()
    private let dataTransferService: DataTransferService
    
    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    /// 응답 값이 있는 요청
    func basicRequest<E: ResponseRequestable>(
        endpoint: E
    ) -> Single<E.Response> where E.Response: Decodable {
        return self.dataTransferService.request(with: endpoint)
            .catch({
                let resolveError = self.handleDatTransferError($0)
                return .error(resolveError)
            })
    }
    
    /// 응답 값이 없는 요청
    func basicRequest<E: ResponseRequestable>(
        endpoint: E
    ) -> Single<Void> where E.Response == Void {
        return self.dataTransferService.request(with: endpoint)
            .catch({
                let resolveError = self.handleDatTransferError($0)
                return .error(resolveError)
            })
    }

    private func handleDatTransferError(_ error: Error) -> DataRequestError {
        guard let transferError = error as? DataTransferError else {
            return DataRequestError.unknown
        }
        return resolveDataTransferError(err: transferError)
    }
    
    private func resolveDataTransferError(err: DataTransferError) -> DataRequestError {
        switch err {
        case let .networkFailure(err):
            switch err {
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

// MARK: - With Token
extension DefaultAppNetWorkService {
    /// 토큰을 사용함으로 토큰 만료 시 재요청(retry)이 필요
    /// - Response 값이 있는 경우
    func authenticatedRequest<E: ResponseRequestable>(
        endpointClosure: @escaping () throws -> E
    ) -> Single<E.Response> where E.Response: Decodable {
        return retryWithToken(
            Single.deferred {
                do {
                    let endpoint = try endpointClosure()
                    return self.basicRequest(endpoint: endpoint)
                } catch {
                    return .error(error)
                }
            }
        )
    }
        
    /// 토큰을 사용함으로 토큰 만료 시 재요청(retry)이 필요
    /// - Response 값이 없는 (Void)
    func authenticatedRequest<E: ResponseRequestable>(
        endpointClosure: @escaping () throws -> E
    ) -> Single<Void> where E.Response == Void {
        return retryWithToken(
            Single.deferred {
                do {
                    let endpoint = try endpointClosure()
                    return self.basicRequest(endpoint: endpoint)
                } catch {
                    return .error(error)
                }
            }
        )
    }
    
    private func retryWithToken<T>(_ source: Single<T>) -> Single<T> {
        return source
            .retry { err in
                err.flatMap { [weak self] err -> Single<Void> in
                    guard let self,
                          let requestError = err as? DataRequestError else {
                        return .error(DataRequestError.unknown)
                    }
                    
                    if requestError == .expiredToken {
                        return reissueTokenIfNeeded().asSingle()
                    } else {
                        return .error(requestError)
                    }
                }
            }
    }
    
    private func reissueTokenIfNeeded() -> Observable<Void> {
        if let ongoingRefresh {
            return ongoingRefresh
        }
        
        let refreshObservable = reissueToken()
            .asObservable()
            .do(onDispose: { [weak self] in
                self?.ongoingRefresh = nil
            })
            .catch({ [weak self] err in
                guard let self else { return .error(err)}
                errorHandlingService.handleError(.expiredToken)
                return .error(DataRequestError.handled)
            })
            .share(replay: 1)
            
        ongoingRefresh = refreshObservable
        return refreshObservable
    }
    
    // 로그인 세션 만료 용 에러 보내기
    private func reissueToken() -> Single<Void> {
        return Single.deferred { [weak self] in
            guard let self else { return .just(()) }
            
            do {
                let refreshEndpoint = try APIEndpoints.reissueToken()
                return self.dataTransferService
                    .request(with: refreshEndpoint)
                    .observe(on: MainScheduler.instance)
                    .flatMap({
                        KeychainStorage.shared.saveToken($0)
                        return .just(())
                    })
            } catch {
                return .error(error)
            }
        }
    }
}


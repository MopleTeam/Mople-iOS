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
    
    /// 토큰을 사용하지 않음으로 재요청(retry)이 필요하지 않은 일반적인 요청
    func basicRequest<T: Decodable, E: ResponseRequestable>(
        endpoint: E
    ) -> Single<T> where E.Response == T {
        return self.dataTransferService.request(with: endpoint)
    }

    /// 토큰을 사용함으로 토큰 만료 시 재요청(retry)이 필요
    /// - Response 값이 있는 경우
    func authenticatedRequest<E: ResponseRequestable>(
        endpointClosure: @escaping () throws -> E
    ) -> Single<E.Response> where E.Response: Decodable {
        return retryWithToken(
            Single.deferred {
                do {
                    let endpoint = try endpointClosure()
                    return self.dataTransferService.request(with: endpoint)
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
                    return self.dataTransferService.request(with: endpoint)
                } catch {
                    return .error(error)
                }
            }
        )
    }
}

extension DefaultAppNetWorkService {
    
    private func retryWithToken<T>(_ source: Single<T>) -> Single<T> {
        return source.retry { err in
            err.flatMap { [weak self] err -> Single<Void> in
                guard let self,
                      let dataTransferErr = err as? DataTransferError else {
                    return .error(DataRequestError.unknown)
                }

                return handleDataTransferError(err: dataTransferErr)
            }.take(1)
        }
    }
    
    private func handleDataTransferError(err: DataTransferError) -> Single<Void> {
        switch err {
        case let .networkFailure(err):
            switch err {
            case .notConnectedInternet:
                errorHandlingService.handleError(.networkUnavailable)
            default:
                errorHandlingService.handleError(.serverUnavailable)
            }
            return .error(DataRequestError.handled)
        case .expiredToken:
            return reissueTokenIfNeeded().asSingle()
        case .noResponse:
            return .error(DataRequestError.noResponse)
        case .badRequest:
            return .error(DataRequestError.handled)
        default:
            errorHandlingService.handleError(.unknown)
            return .error(DataRequestError.handled)
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
            
            guard let refreshEndpoint = try? APIEndpoints.reissueToken() else {
                errorHandlingService.handleError(.expiredToken)
                return .error(DataRequestError.handled)
            }
            
            return self.dataTransferService
                .request(with: refreshEndpoint)
                .observe(on: MainScheduler.instance)
                .flatMap({
                    KeychainStorage.shared.saveToken($0)
                    return .just(())
                })
        }
    }
}


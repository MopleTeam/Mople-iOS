//
//  DefaultGroupRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import Foundation
import RxSwift
import RxRelay

enum AppError: Error {
    case networkUnavailable
    case unknown
    case expiredToken
    case noResponse
    case handled
    
    var info: String? {
        switch self {
        case .networkUnavailable:
            "네트워크 연결을 확인해주세요."
        case .unknown:
            "알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해주세요."
        case .expiredToken:
            "로그인이 만료되었어요"
        default:
            nil
        }
    }
    
    var subInfo: String? {
        switch self {
        case .expiredToken:
            "서비스 이용을 위해 다시 로그인해주세요"
        default:
            nil
        }
    }
}

protocol AppNetworkService {
    func basicRequest<T: Decodable, E: ResponseRequestable>(endpoint: E) -> Single<T> where E.Response == T
    
    func authenticatedRequest<T: Decodable, E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<E.Response> where E.Response == T
    
    func authenticatedRequest<E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<Void> where E.Response == Void
}

final class DefaultAppNetWorkService: AppNetworkService {
   
    private let tokenRefreshSubject = BehaviorRelay<Observable<Void>?>(value: nil)
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
                    // 400 에러
                    // 나머지 에러 여기서
                    return .error(error)
                }
            }
        )
    }
}

extension DefaultAppNetWorkService {
    
    // 해당 화면에서 처리할 것
    // 네트워크 문제 (알림 표시)
    // 알 수 없는 에러
    // 토큰 재발급 및 만료 처리
    // 위 세가지들은 아래로 내릴 때 AppError에서 이미 처리된 에러로 내려보냄
    // 처리가 안된 것들은 AppError로 묶어서 보냄 네트워크단 하위에서 받는 에러는 AppError로 통일됨
    // 처리가 안된 것 noResponse(로그인 -> 회원가입 및 화면 뒤로가기)

    // 토큰 만료 에러
    // 네트워크 에러
    // 언노운 에러
    
    // 404 에러
    private func retryWithToken<T>(_ source: Single<T>) -> Single<T> {
        return source.retry { err in
            err.flatMap { [weak self] err -> Single<Void> in
                print(#function, #line, "#0325 error : \(err)" )
                guard let self,
                      let dataTransferErr = err as? DataTransferError else { return .error(AppError.unknown) }

                return handleDataTransferError(err: dataTransferErr)
            }.take(1)
        }
    }
    
    private func handleDataTransferError(err: DataTransferError) -> Single<Void> {
        switch err {
        case .networkFailure:
            errorHandlingService.handleError(err: .networkUnavailable)
            return .error(AppError.handled)
        case .expiredToken:
            return reissueTokenIfNeeded().asSingle()
        case .noResponse:
            return .error(AppError.noResponse)
        default:
            errorHandlingService.handleError(err: .unknown)
            return .error(AppError.handled)
        }
    }
    
    private func reissueTokenIfNeeded() -> Observable<Void> {
        if let ongoingRefresh = tokenRefreshSubject.value {
            return ongoingRefresh
        }
        
        let refreshObservable = reissueToken()
            .asObservable()
            .do(onDispose: { [weak self] in
                self?.tokenRefreshSubject.accept(nil)
            })
            .catch({ [weak self] err in
                guard let self else { return .error(err)}
                errorHandlingService.handleError(err: .expiredToken)
                return .error(AppError.handled)
            })
            .share(replay: 1)
            
        tokenRefreshSubject.accept(refreshObservable)
        return refreshObservable
    }
    
    // 로그인 세션 만료 용 에러 보내기
    private func reissueToken() -> Single<Void> {
        return Single.deferred { [weak self] in
            guard let self else { return .never() }
            
            guard let refreshEndpoint = try? APIEndpoints.reissueToken() else {
                errorHandlingService.handleError(err: .expiredToken)
                return .error(AppError.handled)
            }
            
            return self.dataTransferService
                .request(with: refreshEndpoint)
                .do {
                    print(#function, #line, "Path : #0325 토근 재발급 \($0) ")
                    KeyChainService.shared.saveToken($0)
                }
                .map { _ in }
        }
    }
}


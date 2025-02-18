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
    case networkError
    case unknownError
    case noDataError
    
    var info: String {
        switch self {
        case .networkError:
            "네트워크 연결을 확인해주세요."
        case .unknownError:
            "알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해주세요."
        case .noDataError:
            "데이터를 불러오지 못했습니다."
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
    
    // 해당 화면에서 처리할 것
    // 네트워크 문제 (알림 표시)
    // 알 수 없는 에러
    // 토큰 재발급 및 만료 처리
    // 위 세가지들은 아래로 내릴 때 AppError에서 이미 처리된 에러로 내려보냄
    // 처리가 안된 것들은 AppError로 묶어서 보냄 네트워크단 하위에서 받는 에러는 AppError로 통일됨
    // 처리가 안된 것 noResponse(로그인 -> 회원가입 및 화면 뒤로가기)

    
    private func retryWithToken<T>(_ source: Single<T>) -> Single<T> {
        return source.retry { err in
            err.flatMap { err -> Single<Void> in
                
                if err is DataTransferError {
                    return self.reissueTokenIfNeeded()
                        .asSingle()
                } else {
                    return .error(err)
                }
            }.take(1)
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
            .share(replay: 1)
            
        tokenRefreshSubject.accept(refreshObservable)
        return refreshObservable
    }
    
    private func reissueToken() -> Single<Void> {
        return Single.deferred {
            guard let refreshEndpoint = try? APIEndpoints.reissueToken() else {
                return .error(TokenError.noJWTToken)
            }
            
            return self.dataTransferService
                .request(with: refreshEndpoint)
                .do { KeyChainService.shared.saveToken($0) }
                .map { _ in }
        }
    }
}


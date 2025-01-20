//
//  DefaultGroupRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import Foundation
import RxSwift

enum AppError: Error {
    case networkError, unknownError
    
    var info: String {
        switch self {
        case .networkError:
            "네트워크 연결을 확인해주세요."
        case .unknownError:
            "잠시 후 다시 시도해주세요."
        }
    }
}

protocol AppNetworkService {
    func basicRequest<T: Decodable, E: ResponseRequestable>(endpoint: E) -> Single<T> where E.Response == T
    
    func authenticatedRequest<T: Decodable, E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<E.Response> where E.Response == T
    
    func authenticatedRequest<E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<Void> where E.Response == Void
}

final class DefaultAppNetWorkService: AppNetworkService {
   
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
    
    #warning("액세스 토큰 만료 여기서 구분")
    private func retryWithToken<T>(_ source: Single<T>) -> Single<T> {
        return source.retry { err in
            err.flatMap { err -> Single<Void> in
                if err is DataTransferError {
                    return self.reissueToken()
                } else {
                    return .error(err)
                }
            }.take(1)
        }
    }
    
    #warning("리트라이 토큰 만료 여기서 구분")
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


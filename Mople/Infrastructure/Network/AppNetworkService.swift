//
//  DefaultGroupRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import Foundation
import RxSwift

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
        return Single.deferred {
            do {
                let endpoint = try endpointClosure()
                return self.dataTransferService.request(with: endpoint)
            } catch {
                return .error(error)
            }
        }.retry { err in
            err.flatMap { err -> Single<Void> in
                if err is DataTransferError {
                    return self.reissueToken()
                } else {
                    return .error(err)
                }
            }.take(1)
        }
    }
    
    /// 토큰을 사용함으로 토큰 만료 시 재요청(retry)이 필요
    /// - Response 값이 없는 (Void)
    func authenticatedRequest<E: ResponseRequestable>(
        endpointClosure: @escaping () throws -> E
    ) -> Single<Void> where E.Response == Void {
        return Single.deferred {
            do {
                let endpoint = try endpointClosure()
                return self.dataTransferService.request(with: endpoint)
            } catch {
                return .error(error)
            }
        }.retry { err in
            err.flatMap { err -> Single<Void> in
                if err is DataTransferError {
                    return self.reissueToken()
                } else {
                    return .error(err)
                }
            }.take(1)
        }
    }
}

extension DefaultAppNetWorkService {
    
    #warning("재발급 실패 로직 여기서 처리")
    private func reissueToken() -> Single<Void> {
        return Single.deferred {
            guard let refreshEndpoint = try? APIEndpoints.reissueToken() else {
                print(#function, #line, "# 2 : 재발급 토근 없음" )
                return .error(TokenError.noJWTToken)
            }
            
            print(#function, #line, "# 2 : 재발급 토근 요청" )
            
            return self.dataTransferService
                .request(with: refreshEndpoint)
                .do { KeyChainService.shared.saveToken($0) }
                .map { _ in }
        }
    }
}


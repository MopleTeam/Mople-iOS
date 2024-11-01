//
//  DefaultGroupRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import Foundation
import RxSwift

protocol AppNetWorkService {
    func basicRequest<T: Decodable, E: ResponseRequestable>(endpoint: E) -> Single<T> where E.Response == T
    
    func authenticatedRequest<T: Decodable, E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<E.Response> where E.Response == T
    
    func authenticatedRequest<E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<Void> where E.Response == Void
}

final class DefaultAppNetWorkService: AppNetWorkService {
   
    private let dataTransferService: DataTransferService
    
    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    /// 토큰을 사용하지 않음으로 재요청(retry)이 필요하지 않은 일반적인 요청
    func basicRequest<T: Decodable, E: ResponseRequestable>(endpoint: E) -> Single<T> where E.Response == T {
        return Single.create { emitter in
                        
            let task = self.performRequest(endpoint: endpoint)
                .subscribe(onSuccess: { result in
                    emitter(.success(result))
                }, onFailure: { err in
                    emitter(.failure(err))
                })

            return task
        }
    }

    /// 토큰을 사용함으로 토큰 만료 시 재요청(retry)이 필요
    /// Response 값이 있는 경우
    func authenticatedRequest<T: Decodable, E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<E.Response> where E.Response == T {
        return Single.deferred {
            do {
                let endpoint = try endpointClosure()
                return self.performRequest(endpoint: endpoint)
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
    /// Response 값이 없는 (Void)
    func authenticatedRequest<E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<Void> where E.Response == Void {
        return Single.deferred {
            do {
                let endpoint = try endpointClosure()
                return self.performRequest(endpoint: endpoint)
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
    private func performRequest<T: Decodable, E: ResponseRequestable>(endpoint: E) -> Single<T> where E.Response == T {
        return Single.create { emitter in
            let task = self.dataTransferService.request(with: endpoint)
                .subscribe(
                    onSuccess: { response in
                        emitter(.success(response))
                    },
                    onFailure: { error in
                        emitter(.failure(error))
                    }
                )
            return task
        }
    }
    
    private func performRequest<E: ResponseRequestable>(endpoint: E) -> Single<Void> where E.Response == Void {
        return Single.create { emitter in
            let task = self.dataTransferService.request(with: endpoint)
                .subscribe(
                    onSuccess: { response in
                        emitter(.success(()))
                    },
                    onFailure: { error in
                        emitter(.failure(error))
                    }
                )
            return task
        }
    }
}

extension DefaultAppNetWorkService {
    private func reissueToken() -> Single<Void> {
        return Single.create { emitter in
            do {
                let endpoint = try APIEndpoints.reissueToken()
    
                return self.dataTransferService.request(with: endpoint)
                    .subscribe(onSuccess: { accessToken in
                        KeyChainService.shared.reissueToken(accessToken: accessToken)
                        emitter(.success(()))
                    }, onFailure: { err in
                        emitter(.failure(err))
                    })
                
            } catch {
                emitter(.failure(error))
                return Disposables.create()
            }
        }
    }
}

//
//  DefaultGroupRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import Foundation
import RxSwift

final class GroupRepository {
    
    private let dataTransferService: DataTransferService
    private var tokenKeyChainService: KeyChainService?
    
    init(dataTransferService: DataTransferService,
         tokenKeyCahinService: KeyChainService? = nil) {
        self.dataTransferService = dataTransferService
        self.tokenKeyChainService = tokenKeyCahinService
    }
}

// MARK: - Retry Request
#warning("만료 에러코드 작업필요")
extension GroupRepository {
    private func reissueToken() -> Single<Void> {
        return Single.create { emitter in
            print("토큰 재발급 요청")
            do {
                let endpoint = try APIEndpoints.reissueToken()
                
                let task = self.dataTransferService.request(with: endpoint)
                    .subscribe(onSuccess: { accessToken in
                        self.tokenKeyChainService?.reissueToken(accessToken: accessToken)
                        emitter(.success(()))
                    }, onFailure: { err in
                        emitter(.failure(err))
                    })
                
                return task
            } catch {
                emitter(.failure(error))
                return Disposables.create()
            }
        }
    }
    
    private func requestWithRetry<T: Decodable, E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<E.Response> where E.Response == T {
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
    
    private func requestWithRetry<E: ResponseRequestable>(endpointClosure: @escaping () throws -> E) -> Single<Void> where E.Response == Void {
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

// MARK: - Login
extension GroupRepository: LoginRepository {
    func userLogin(authCode: String) -> Single<Void> {
        let endpoint = APIEndpoints.login(code: authCode)
        
        return Single.create { emitter in
                        
            let task = self.dataTransferService.request(with: endpoint)
                .subscribe(with: self, onSuccess: { repo, token in
                    repo.tokenKeyChainService?.saveToken(token)
                    emitter(.success(()))
                }, onFailure: { _, err in
                    emitter(.failure(err))
                })
            return task
        }
    }
}

// MARK: - Profile Setup
extension GroupRepository: ProfileSetupRepository {
    func getRandomNickname() -> Single<Data> {
        return requestWithRetry { () throws -> Endpoint<Data> in
            try APIEndpoints.getRandomNickname()
        }
    }
    
    func checkNickname(name: String) -> Single<Bool> {
        return requestWithRetry(endpointClosure: { () throws -> Endpoint<Bool> in
            try APIEndpoints.checkNickname(name: name)
        })
    }
    
    func makeProfile(image: Data, nickNmae: String) -> Single<Void> {
        return requestWithRetry { () throws -> Endpoint<Void> in
            try APIEndpoints.setupProfile(image: image, nickName: nickNmae)
        }
    }
}




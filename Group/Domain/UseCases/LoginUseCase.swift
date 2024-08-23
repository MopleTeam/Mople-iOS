//
//  LoginUseCase.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import Foundation
import RxSwift

protocol LoginUseCase {
    func login() -> Single<Void>
}

final class DefaultLoginUseCase: LoginUseCase {
    
    let appleLoginService: AppleLoginService
    let userRepository: UserRepository
    
    init(appleLoginService: AppleLoginService,
         userRepository: UserRepository) {
        self.appleLoginService = appleLoginService
        self.userRepository = userRepository
    }
    
    func login() -> Single<Void> {
        
        return Single.create { [weak self] emitter in
            guard let self = self else {
                return Disposables.create()
            }
            
            let task = self.appleLoginService.startAppleLogin()
                .flatMap { self.userRepository.userLogin(authCode: $0)}
                .subscribe(onSuccess: { code in
                    emitter(.success(()))
                }, onFailure: { err in
                    emitter(.failure(err))
                })
            return task
        }
    }
}

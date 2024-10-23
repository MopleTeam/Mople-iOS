//
//  LoginUseCase.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import Foundation
import RxSwift

protocol UserLogin {
    func login() -> Single<Void>
}

final class UserLoginImpl: UserLogin {
    
    let appleLoginService: AppleLoginService
    let repository: LoginRepository
    
    init(appleLoginService: AppleLoginService,
         userRepository: LoginRepository) {
        self.appleLoginService = appleLoginService
        self.repository = userRepository
    }
    
    func login() -> Single<Void> {
        
        return Single.create { emitter in

            let task = self.appleLoginService.startAppleLogin()
                .flatMap { self.repository.userLogin(authCode: $0)}
                .subscribe(onSuccess: { code in
                    print("login apple code: \(code)")
                    emitter(.success(()))
                }, onFailure: { err in
                    emitter(.failure(err))
                })
            
            return task
        }
    }
}

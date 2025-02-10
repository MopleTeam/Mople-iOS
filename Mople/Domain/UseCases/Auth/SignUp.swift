//
//  LoginUseCase.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit
import RxSwift

protocol SignUp {
    func execute(request: SignUpRequest) -> Single<Void>
}

final class SignUpUseCase: SignUp {

    private let authenticationRepo: AuthenticationRepo
    
    init(authenticationRepo: AuthenticationRepo) {
        print(#function, #line, "LifeCycle Test SignInUseCase Created" )
        self.authenticationRepo = authenticationRepo
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SignInUseCase Deinit" )
    }
    
    // MARK: - SignUp
    func execute(request: SignUpRequest) -> Single<Void> {
        return self.authenticationRepo.signUp(requestModel: request)
    }
}

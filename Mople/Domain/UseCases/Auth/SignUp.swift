//
//  LoginUseCase.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import RxSwift

protocol SignUp {
    func execute(request: SignUpRequest) -> Single<Void>
}

final class SignUpUseCase: SignUp, LifeCycleLoggable {

    private let repo: AuthenticationRepo
    
    init(repo: AuthenticationRepo) {
        self.repo = repo
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - SignUp
    func execute(request: SignUpRequest) -> Single<Void> {
        return repo.signUp(requestModel: request)
    }
}

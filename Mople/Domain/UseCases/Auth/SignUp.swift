//
//  LoginUseCase.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import RxSwift

protocol SignUp {
    func execute(request: SignUpRequest) -> Observable<Void>
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
    func execute(request: SignUpRequest) -> Observable<Void> {
        return repo.signUp(requestModel: request)
            .asObservable()
    }
}

//
//  SignOut.swift
//  Mople
//
//  Created by CatSlave on 4/18/25.
//

import RxSwift

protocol SignOut {
    func execute(userId: Int) -> Single<Void>
}

final class SignOutUseCase: SignOut, LifeCycleLoggable {
    
    private let repo: AuthenticationRepo
    
    init(repo: AuthenticationRepo) {
        self.repo = repo
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func execute(userId: Int) -> Single<Void> {
        return repo.signOut(userId: userId)
    }
}

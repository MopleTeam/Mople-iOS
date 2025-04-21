//
//  DeleteAccount.swift
//  Mople
//
//  Created by CatSlave on 4/18/25.
//

import RxSwift

protocol DeleteAccount {
    func execute() -> Single<Void>
}

final class DeleteAccountUseCase: DeleteAccount, LifeCycleLoggable {
    
    private let repo: AuthenticationRepo
    
    init(repo: AuthenticationRepo) {
        self.repo = repo
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func execute() -> Single<Void> {
        return repo.deleteAccount()
    }
}

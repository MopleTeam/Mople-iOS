//
//  DeleteAccount.swift
//  Mople
//
//  Created by CatSlave on 4/18/25.
//

import RxSwift

protocol DeleteAccount {
    func execute() -> Observable<Void>
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
    
    func execute() -> Observable<Void> {
        return repo.deleteAccount()
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockDeleteAccountUseCase: DeleteAccount {

    func execute() -> Observable<Void> {
        print("✅ [Mock] 계정 삭제 요청")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print("✅ [Mock] 계정 삭제 성공") })
    }
}
#endif

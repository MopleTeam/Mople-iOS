//
//  SignOut.swift
//  Mople
//
//  Created by CatSlave on 4/18/25.
//

import RxSwift

protocol SignOut {
    func execute(userId: Int) -> Observable<Void>
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
    
    func execute(userId: Int) -> Observable<Void> {
        return repo.signOut(userId: userId)
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockSignOutUseCase: SignOut {

    func execute(userId: Int) -> Observable<Void> {
        print("✅ [Mock] 로그아웃 요청 - userId: \(userId)")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print("✅ [Mock] 로그아웃 성공") })
    }
}
#endif

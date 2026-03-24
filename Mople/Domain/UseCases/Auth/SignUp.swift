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

// MARK: - Mock UseCase
#if DEV
final class MockSignUpUseCase: SignUp {

    func execute(request: SignUpRequest) -> Observable<Void> {
        print("✅ [Mock] 회원가입 요청")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print("✅ [Mock] 회원가입 성공") })
    }
}
#endif

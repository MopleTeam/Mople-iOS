//
//  LoginViewModel.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import RxSwift
import RxRelay

protocol LoginViewModel {
    func transform(input: ViewModelInput) -> LoginOutput
}

struct LoginViewModelAction {
    var showProfileView: () -> Void
}

struct ViewModelInput {
    let login: Observable<Void>
}

struct LoginOutput {
    let notifyError: Observable<String>
}

final class DefaultLoginViewModel: LoginViewModel {
    
    private let loginUseCase: UserLogin
    private let action: LoginViewModelAction?
    
    let disposeBag = DisposeBag()
    
    private let errorAccrued: PublishSubject<String> = .init()
    
    init(loginUseCase: UserLogin, action: LoginViewModelAction) {
        self.loginUseCase = loginUseCase
        self.action = action
    }
    
    func transform(input: ViewModelInput) -> LoginOutput {
        input.login
            .bind(with: self, onNext: { vm, _ in
                vm.executeLogin()
                
            }).disposed(by: disposeBag)
        
        return LoginOutput(notifyError: errorAccrued.asObservable())
    }
    private func executeLogin() {
        loginUseCase.login()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onSuccess: { vm, _ in
                vm.showProfileView()
            }, onFailure: { vm, err in
                if let loginErr = err as? LoginError {
                    vm.errorAccrued.onNext(loginErr.message)
                } else {
                    vm.errorAccrued.onNext("로그인 실패")
                }
            }).disposed(by: disposeBag)
    }
    
    private func showProfileView() {
        action?.showProfileView()
    }
}

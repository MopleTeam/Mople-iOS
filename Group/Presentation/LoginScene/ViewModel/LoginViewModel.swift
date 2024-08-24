//
//  LoginViewModel.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import RxSwift
import RxRelay

protocol LoginViewModel {
    func transform(input: ViewModelInput<Void>) -> LoginOutput
}

struct LoginViewModelAction {
    var showProfileView: () -> Void
}

struct ViewModelInput<T> {
    let login: Observable<T>
}

struct LoginOutput {
    let notifyError: Observable<String>
}

final class DefaultLoginViewModel: LoginViewModel {
    
    private let loginUseCase: LoginUseCase
    private let action: LoginViewModelAction?
    
    let disposeBag = DisposeBag()
    
    private let errorAccrued: PublishSubject<String> = .init()
    
    init(loginUseCase: LoginUseCase, action: LoginViewModelAction) {
        self.loginUseCase = loginUseCase
        self.action = action
    }
    
    func transform(input: ViewModelInput<Void>) -> LoginOutput {
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

// MARK: - Action
extension DefaultLoginViewModel {
//    private func showProfileView() {
//        
//    }
}

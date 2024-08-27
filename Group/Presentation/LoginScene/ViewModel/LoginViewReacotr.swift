//
//  LoginViewModel.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import ReactorKit
import RxSwift
import RxRelay

struct LoginAction {
    var showProfileView: () -> Void
}

enum LoginFacingError: Error {
    case noAuthCode
    case completedError
    case unknownError(err: Error)
    
    var info: String {
        switch self {
        case .noAuthCode:
            "Apple ID 정보를 확인하고\n다시 시도해 주세요"
        case .completedError:
            "로그인에 실패했습니다.\n다시 시도해 주세요."
        case .unknownError(_):
            "알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요."
        }
    }
}

final class LoginViewReacotr: Reactor {
    
    enum Action {
        case executeLogin
    }
    
    enum Mutation {
        case showProfileView
        case catchError(err: Error)
    }
    
    struct State {
        var errorMessage: String? = nil
    }
    
    private let loginUseCase: UserLogin
    private let loginAction: LoginAction?
    
    var initialState: State = State()
    
    init(loginUseCase: UserLogin, loginAction: LoginAction) {
        self.loginUseCase = loginUseCase
        self.loginAction = loginAction
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .showProfileView:
            loginAction?.showProfileView()
        case .catchError(let err):
            newState = handleError(state: newState, err: err)
        }
  
        return newState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .executeLogin:
            self.executeLogin()
        }
    }
    
    func handleError(state: State, err: Error) -> State {
        var newState = state
        
        if let err = err as? LoginError {
            switch err {
            case .noAuthCode:
                newState.errorMessage = LoginFacingError.noAuthCode.info
            case .completeError:
                newState.errorMessage = LoginFacingError.completedError.info
            }
        } else {
            newState.errorMessage = LoginFacingError.unknownError(err: err).info
        }
        
        return newState
    }
}

extension LoginViewReacotr {
    private func executeLogin() -> Observable<Mutation> {
        let loginTask = loginUseCase.login()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .map { _ in Mutation.showProfileView }
            .catch { err in
                return Observable.just(Mutation.catchError(err: err))
            }
        
        return loginTask
    }
}

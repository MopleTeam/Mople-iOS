//
//  LoginViewModel.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import ReactorKit
import RxSwift
import RxRelay

struct SignInAction {
    var toProfileSetup: (SocialAccountInfo) -> Void
    var toMain: () -> Void
}

final class SignInViewReactor: Reactor {
    
    enum Action {
        case appleLogin
        case kakaoLogin
    }
    
    enum Mutation {
        case moveToProfileSetup(_ socialInfo: SocialAccountInfo)
        case moveToMain
        case notifyMessage(message: String?)
        case setLoading(isLoad: Bool)
    }
    
    struct State {
        @Pulse var message: String? = nil
        @Pulse var isLoading: Bool = false
    }
    
    private let userLoginUseCase: SignIn
    private let loginAction: SignInAction
    
    var initialState: State = State()
    
    init(loginUseCase: SignIn, loginAction: SignInAction) {
        self.userLoginUseCase = loginUseCase
        self.loginAction = loginAction
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .notifyMessage(let message):
            newState.message = message
        case .setLoading(let isLoad):
            newState.isLoading = isLoad
        case .moveToProfileSetup(let SocialAccountInfo):
            loginAction.toProfileSetup(SocialAccountInfo)
        case .moveToMain:
            print(#function, #line, "# 30" )
            loginAction.toMain()
        }
  
        return newState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .appleLogin:
            self.executeLogin(.apple)
        case .kakaoLogin:
            self.executeLogin(.kakao)
        }
    }
}




// MARK: - Execute
extension SignInViewReactor {
    private func executeLogin(_ platform: LoginPlatform) -> Observable<Mutation> {
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
                
        let loginTask = userLoginUseCase.login(platform)
            .asObservable()
            .map { _ in Mutation.moveToMain }
            .catch { self.handleError(err: $0) }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))
      
        
        return Observable.concat([loadingOn,
                                  loginTask,
                                  loadingOff])
    }
}

// MARK: - 로그인 에러 핸들링
extension SignInViewReactor {
    private func handleError(err: Error) -> Observable<Mutation> {
        switch err {
        case LoginError.notFoundInfo(let socialAccountInfo):
            return .just(.moveToProfileSetup(socialAccountInfo))
        case let err as LoginError:
            return .just(.notifyMessage(message: err.info))
        case let err as AppError:
            return .just(.notifyMessage(message: err.info))
        default:
            return .just(.notifyMessage(message: AppError.unknownError.info))
        }
    }
}

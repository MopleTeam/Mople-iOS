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
    var toProfileSetup: (SocialInfo) -> Void
    var toMain: () -> Void
}

final class SignInViewReactor: Reactor {
    
    enum Action {
        case appleLogin
        case kakaoLogin
    }
    
    enum Mutation {
        case moveToProfileSetup(_ socialInfo: SocialInfo)
        case moveToMain
        case notifyMessage(message: String?)
        case setLoading(isLoad: Bool)
    }
    
    struct State {
        @Pulse var message: String? = nil
        @Pulse var isLoading: Bool = false
    }
    
    private let userLoginUseCase: SignIn
    private let fetchUserInfoUseCase: FetchUserInfo
    private let loginAction: SignInAction
    
    var initialState: State = State()
    
    init(loginUseCase: SignIn,
         fetchUserInfoUseCase: FetchUserInfo,
         loginAction: SignInAction) {
        print(#function, #line, "LifeCycle Test SignIn View Reactor Created" )
        self.userLoginUseCase = loginUseCase
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        self.loginAction = loginAction
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SignIn View Reactor Deinit" )
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .notifyMessage(let message):
            newState.message = message
        case .setLoading(let isLoad):
            newState.isLoading = isLoad
        case .moveToProfileSetup(let socialInfo):
            loginAction.toProfileSetup(socialInfo)
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
            .flatMap({ [weak self] in
                guard let self else { throw AppError.unknownError }
                return self.fetchUserInfoUseCase.fetchUserInfo()
            })
            .asObservable()
            .map { Mutation.moveToMain }
            .catch { [weak self] err in
                guard let self else { throw AppError.unknownError }
                return self.handleError(err: err)
            }
        
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
        case LoginError.notFoundInfo(let socialInfo):
            return Observable.just(())
                .subscribe(on: MainScheduler.instance)
                .map { _ in .moveToProfileSetup(socialInfo) }
        case let err as LoginError:
            return .just(.notifyMessage(message: err.info))
        case let err as AppError:
            return .just(.notifyMessage(message: err.info))
        default:
            return .just(.notifyMessage(message: AppError.unknownError.info))
        }
    }
}

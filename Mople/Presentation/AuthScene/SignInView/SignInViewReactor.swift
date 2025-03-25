//
//  LoginViewModel.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import ReactorKit
import RxSwift
import RxRelay

final class SignInViewReactor: Reactor, LifeCycleLoggable {
    
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
    
    private let signIn: SignIn
    private let fetchUserInfo: FetchUserInfo
    private weak var coordinator: AuthFlowCoordination?
    
    var initialState: State = State()
    
    init(signInUseCase: SignIn,
         fetchUserInfoUseCase: FetchUserInfo,
         coordinator: AuthFlowCoordination) {
        self.signIn = signInUseCase
        self.fetchUserInfo = fetchUserInfoUseCase
        self.coordinator = coordinator
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .notifyMessage(message):
            newState.message = message
        case let .setLoading(isLoad):
            newState.isLoading = isLoad
        case let .moveToProfileSetup(socialInfo):
            coordinator?.pushSignUpView(socialInfo)
        case .moveToMain:
            coordinator?.presentMainFlow()
        }
  
        return newState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .appleLogin:
            self.executeSignIn(platform: .apple)
        case .kakaoLogin:
            self.executeSignIn(platform: .kakao)
        }
    }
}




// MARK: - Execute
extension SignInViewReactor {
    private func executeSignIn(platform: LoginPlatform) -> Observable<Mutation> {
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
                
        let loginTask = signIn.execute(platform: platform)
            .flatMap({ [weak self] in
                guard let self else { throw AppError.unknown }
                return self.fetchUserInfo.execute()
            })
            .asObservable()
            .map { Mutation.moveToMain }
            .catch { [weak self] err in
                guard let self else { throw AppError.unknown }
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
                .observe(on: MainScheduler.instance)
                .map { _ in .moveToProfileSetup(socialInfo) }
        case let err as LoginError:
            return .just(.notifyMessage(message: err.info))
        case let err as AppError:
            return .just(.notifyMessage(message: err.info))
        default:
            return .just(.notifyMessage(message: AppError.unknown.info))
        }
    }
}

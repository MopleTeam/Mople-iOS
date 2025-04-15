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
        case catchError(LoginError?)
    }
    
    struct State {
        @Pulse var error: LoginError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    
    // MARK: - UseCase
    private let signIn: SignIn
    private let fetchUserInfo: FetchUserInfo
    
    // MARK: - Coordinator
    private weak var coordinator: AuthFlowCoordination?
    
    // MARK: - LifeCycle
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
    
    // MARK: - State Mutation
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .catchError(err):
            newState.error = err
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

// MARK: - Data Request
extension SignInViewReactor {
    private func executeSignIn(platform: LoginPlatform) -> Observable<Mutation> {
                  
        return signIn.execute(platform: platform)
            .flatMap({ [weak self] _ -> Single<Void> in
                guard let self else { return .just(()) }
                return self.fetchUserInfo.execute()
            })
            .observe(on: MainScheduler.instance)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<Mutation> in
                self?.coordinator?.presentMainFlow()
                return .empty()
            }
            .catch({ [weak self] err -> Observable<Mutation> in
                guard let self else { return .empty() }
                let err = handleError(err)
                return .just(.catchError(err))
            })
    }
    
    private func handleError(_ err: Error) -> LoginError? {
        guard let loginErr = err as? LoginError else {
            return .unknown(err)
        }
        
        switch loginErr {
        case let .notFoundInfo(socialInfo):
            coordinator?.pushSignUpView(socialInfo)
            return nil
        case .cancle, .handled:
            return nil
        default:
            return loginErr
        }
    }
}

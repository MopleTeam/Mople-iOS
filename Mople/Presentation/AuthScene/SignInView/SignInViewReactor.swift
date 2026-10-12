//
//  LoginViewModel.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import ReactorKit
import Domain
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
    /// 로그인 실행 후 유저 정보 조회, 성공 시 메인 화면 전환
    private func executeSignIn(platform: LoginPlatform) -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    try await self?.signIn.execute(platform: platform)
                    try await self?.fetchUserInfo.execute()
                    await MainActor.run {
                        self?.coordinator?.presentMainFlow()
                    }
                    observer.onCompleted()
                } catch {
                    guard let self else {
                        observer.onCompleted()
                        return
                    }
                    let loginErr = self.handleError(error)
                    observer.onNext(.catchError(loginErr))
                    observer.onCompleted()
                }
            }
            return Disposables.create { task.cancel() }
        }
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

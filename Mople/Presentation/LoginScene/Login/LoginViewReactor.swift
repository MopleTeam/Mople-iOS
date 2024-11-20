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
    var logIn: () -> Void
}

enum LoginFacingError: Error {
    case noAuthCodeError
    case completedError
    case networkError
    case serverError
    case parsingError
    case unknownError(err: Error)
    
    var info: String {
        switch self {
        case .noAuthCodeError:
            "Apple ID 정보를 확인하고\n다시 시도해 주세요"
        case .completedError:
            "로그인에 실패했습니다.\n다시 시도해 주세요."
        case .unknownError(_):
            "알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요."
        case .networkError:
            "네트워크 연결을 확인해주세요."
        case .serverError:
            "서버에 문제가 발생했습니다.\n잠시 후 다시 시도해 주세요."
        case .parsingError:
            "데이터에 문제가 발생했습니다.\n앱을 최신 버전으로 업데이트해 주세요."
        }
    }
}

final class LoginViewReactor: Reactor {
    
    enum Action {
        case appleLogin
        case kakaoLogin
    }
    
    enum Mutation {
        case showProfileView
        case catchError(err: Error)
        case setLoading(isLoad: Bool)
    }
    
    struct State {
        @Pulse var errorMessage: String? = nil
        @Pulse var isLoading: Bool = false
    }
    
    private let userLoginUseCase: UserLogin
    private let loginAction: LoginAction
    
    var initialState: State = State()
    
    init(loginUseCase: UserLogin, loginAction: LoginAction) {
        self.userLoginUseCase = loginUseCase
        self.loginAction = loginAction
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .showProfileView:
            loginAction.logIn()
        case .catchError(let err):
            newState = handleError(state: newState, err: err)
        case .setLoading(let isLoad):
            newState.isLoading = isLoad
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
    
    func handleError(state: State, err: Error) -> State {
        var newState = state
        
        switch err {
        case let err as DataTransferError:
            let loginError = mapDataErrorToFacingError(err: err)
            newState.errorMessage = loginError.info
        case let err as LoginError:
            let loginError = mapLoginErrorToFacingError(err: err)
            newState.errorMessage = loginError.info
        default:
            newState.errorMessage = LoginFacingError.unknownError(err: err).info
        }
        
        return newState
    }
}

// MARK: - Error Handler
extension LoginViewReactor {
    private func mapLoginErrorToFacingError(err : LoginError) -> LoginFacingError {
        switch err {
        case .noAuthCode:
            LoginFacingError.noAuthCodeError
        case .completeError:
            LoginFacingError.completedError
        }
    }
    
    private func mapDataErrorToFacingError(err : DataTransferError) -> LoginFacingError {
        switch err {
        case .parsing(_): .parsingError
        case .noResponse: .completedError
        case .networkFailure(_): .networkError
        case .resolvedNetworkFailure(_): .serverError
        }
    }
}

// MARK: - Execute
extension LoginViewReactor {
    private func executeLogin(_ platform: LoginPlatform) -> Observable<Mutation> {
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
                
        let loginTask = userLoginUseCase.login(platform)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .map { _ in Mutation.showProfileView }
            .catch { Observable.just(Mutation.catchError(err: $0))}
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))
      
        
        return Observable.concat([loadingOn,
                                  loginTask,
                                  loadingOff])
    }
}

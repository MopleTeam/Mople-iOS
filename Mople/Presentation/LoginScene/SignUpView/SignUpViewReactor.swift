//
//  ProfileCreateViewReacotr.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import UIKit
import ReactorKit

struct SignUpAction {
    var completed: (() -> Void)?
}

class SignUpViewReactor: Reactor {

    enum Action {
        case setLoading(isLoad: Bool)
        case getRandomNickname
        case singUp(name: String?, image: UIImage?)
    }
    
    enum Mutation {
        case getRandomNickname(name: String?)
        case singUpCompleted
        case notifyMessage(message: String?)
        case setLoading(isLoad: Bool)
    }
    
    struct State {
        @Pulse var randomName: String?
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
    }
    
    private let signUpUseCase: SignUp
    private var completedAction: SignUpAction
    private let fetchUserInfoUseCase: FetchUserInfo
    private var socialInfo: SocialInfo
    
    var initialState: State = State()
    
    init(socialInfo: SocialInfo,
         signUpUseCase: SignUp,
         fetchUserInfoUseCase: FetchUserInfo,
         completedAction: SignUpAction) {
        print(#function, #line, "LifeCycle Test SignUp Reactor Created" )
        self.socialInfo = socialInfo
        self.signUpUseCase = signUpUseCase
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        self.completedAction = completedAction
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SignUp Reactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getRandomNickname:
            return getRandomNickname()
        case let .singUp(nickname, image):
            return signUp(nickname, image)
        case .setLoading(let isLoad):
            return .just(.setLoading(isLoad: isLoad))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .getRandomNickname(let name):
            newState.randomName = name
        case .singUpCompleted:
            completedAction.completed?()
        case .notifyMessage(let message):
            newState.message = message
        case .setLoading(let isLoad):
            newState.isLoading = isLoad
        }
        
        return newState
    }
    
    func handleError(err: Error) -> String {
        switch err {
        case NetworkError.notConnected:
            return AppError.networkError.info
        default:
            return AppError.unknownError.info
        }
    }
}

extension SignUpViewReactor {
    
    private func getRandomNickname() -> Observable<Mutation> {
        let loadStart = Observable.just(Mutation.setLoading(isLoad: true))
        
        let randomName = signUpUseCase.getRandomNickname()
            .asObservable()
            .map { Mutation.getRandomNickname(name: $0) }
            .catch { Observable.just(Mutation.notifyMessage(message: self.handleError(err: $0))) }
        
        let loadEnd = Observable.just(Mutation.setLoading(isLoad: false))
            
        return Observable.concat([loadStart,
                                  randomName,
                                  loadEnd])
    }
    
    private func signUp(_ name: String?,_ image: UIImage?) -> Observable<Mutation> {
        guard let name else {
            return Observable.just(Mutation.notifyMessage(message: NickNameValidator.ValidatorError.empty.info))
        }
        
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
        
        let makeProfile = signUpUseCase.signUp(nickname: name,
                                               image: image,
                                               social: socialInfo)
            .flatMap({ [weak self] in
                guard let self else { throw AppError.unknownError }
                return self.fetchUserInfoUseCase.fetchUserInfo()
            })
            .asObservable()
            .map({ _ in Mutation.singUpCompleted })
            .catch { Observable.just(Mutation.notifyMessage(message: self.handleError(err: $0))) }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))

            
        return Observable.concat([loadingOn,
                                  makeProfile,
                                  loadingOff])
    }
}

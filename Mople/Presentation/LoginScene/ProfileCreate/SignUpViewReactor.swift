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
    private var socialAccountInfo: SocialAccountInfo
    
    var initialState: State = State()
    
    init(socialAccountInfo: SocialAccountInfo,
         signUpUseCase: SignUp,
         completedAction: SignUpAction) {
        self.socialAccountInfo = socialAccountInfo
        self.signUpUseCase = signUpUseCase
        self.completedAction = completedAction
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getRandomNickname:
            return getRandomNickname()
        case let .singUp(nickname, image):
            return singUp(nickname, image)
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
    
    private func singUp(_ name: String?,_ image: UIImage?) -> Observable<Mutation> {
        guard let name else { return .empty() }
        
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
        
        let makeProfile = signUpUseCase.signUp(nickname: name,
                                               image: image,
                                               socialAccountInfo: socialAccountInfo)
            .asObservable()
            .map({ _ in Mutation.singUpCompleted })
            .catch { [weak self] err in
                let errMeesage =  Observable.just(Mutation.notifyMessage(message: self?.handleError(err: err)))
                
                return Observable.concat([errMeesage])
            }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))

            
        return Observable.concat([loadingOn,
                                  makeProfile,
                                  loadingOff])
    }
}

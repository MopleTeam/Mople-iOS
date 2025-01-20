//
//  ProfileCreateViewReacotr.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import UIKit
import ReactorKit

class SignUpViewReactor: Reactor, LifeCycleLoggable {

    enum Action {
        case setLoading(isLoad: Bool)
        case singUp(name: String, image: UIImage?)
    }
    
    enum Mutation {
        case singUpCompleted
        case notifyMessage(message: String?)
        case setLoading(isLoad: Bool)
    }
    
    struct State {
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
    }
    
    private let signUpUseCase: SignUp
    private let imageUploadUseCase: ImageUpload
    private let fetchUserInfo: FetchUserInfo
    private var coordinator: AuthFlowCoordinating
    
    var initialState: State = State()
    
    init(imageUploadUseCase: ImageUpload,
         signUpUseCase: SignUp,
         fetchUserInfo: FetchUserInfo,
         coordinator: AuthFlowCoordinating) {
        self.signUpUseCase = signUpUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.fetchUserInfo = fetchUserInfo
        self.coordinator = coordinator
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .singUp(nickname, image):
            return signUp(nickname, image)
        case .setLoading(let isLoad):
            return .just(.setLoading(isLoad: isLoad))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .singUpCompleted:
            coordinator.presentMainFlow()
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
    
    private func signUp(_ name: String,_ image: UIImage?) -> Observable<Mutation> {

        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
        
        let createProfile = imageUploadUseCase.execute(image)
            .flatMap { [weak self] imagePath in
                guard let self else { return .error(AppError.unknownError)}
                return self.signUpUseCase
                    .execute(nickname: name, imagePath: imagePath)
            }
            .flatMap({ [weak self] in
                guard let self else { throw AppError.unknownError }
                return self.fetchUserInfo.execute()
            })
            .asObservable()
            .map({ _ in Mutation.singUpCompleted })
            .catch { Observable.just(Mutation.notifyMessage(message: self.handleError(err: $0))) }
            
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))

            
        return Observable.concat([loadingOn,
                                  createProfile,
                                  loadingOff])
    }
}

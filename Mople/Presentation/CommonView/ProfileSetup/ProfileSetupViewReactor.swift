//
//  ProfileSetupViewModel.swift
//  Group
//
//  Created by CatSlave on 8/25/24.
//

import UIKit
import ReactorKit

class ProfileSetupViewReactor: Reactor {

    enum Action {
        case checkNickname(name: String)
    }
    
    enum Mutation {
        case nameCheck(isOverlap: Bool?)
        case notifyMessage(message: String?)
        case setLoading(isLoad: Bool)
    }
    
    struct State {
        @Pulse var nameOverlap: Bool?
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
    }
    
    private let validatorNicknameUseCase: ValidatorNickname
    
    var initialState: State = State()
    
    init(useCase: ValidatorNickname) {
        print(#function, #line, "LifeCycle Test ProfileSetup Reactor Created" )
        self.validatorNicknameUseCase = useCase
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test ProfileSetup Reactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .checkNickname(let name):
            return nickNameValidCheck(name: name)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .nameCheck(let isOverlap):
            newState.nameOverlap = isOverlap
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
        case let err as NickNameValidator.ValidatorError:
            return err.info
        default:
            return AppError.unknownError.info
        }
    }
}

extension ProfileSetupViewReactor {
    
    private func nickNameValidCheck(name: String) -> Observable<Mutation> {
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
        
        let nicknameValidator = validatorNicknameUseCase.validatorNickname(name)
            .asObservable()
            .map { Mutation.nameCheck(isOverlap: $0)}
            .catch { [weak self] err in
                return Observable.just(Mutation.notifyMessage(message: self?.handleError(err: err)))
            }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))
        return Observable.concat([loadingOn,
                                  nicknameValidator,
                                  loadingOff])
    }
}


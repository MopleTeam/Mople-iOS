//
//  ProfileSetupViewModel.swift
//  Group
//
//  Created by CatSlave on 8/25/24.
//

import Foundation
import ReactorKit

final class ProfileSetupViewReactor: Reactor {
    
    enum Action {
        case checkNickname(name: String)
    }
    
    enum Mutation {
        case nameCheck(isOverlap: Bool)
    }
    
    struct State {
        @Pulse var nameOverlap: Bool = false
    }
    
    let profileSetupUseCase: ProfileSetupUseCase
    
    var initialState: State = State()
    
    init(profileSetup: ProfileSetupUseCase) {
        self.profileSetupUseCase = profileSetup
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .checkNickname(let name):
            return checkName(name: name)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .nameCheck(let isOverlap):
            newState.nameOverlap = isOverlap
        }
  
        return newState
    }
    
    func handleError(state: State, err: Error) -> State {
        var newState = state

        return newState
    }
}

extension ProfileSetupViewReactor {
    
    private func checkName(name: String) -> Observable<Mutation> {
        
        let nameOverlap = profileSetupUseCase.checkNickName(name: name)
            .map({ Mutation.nameCheck(isOverlap: $0)})
            .asObservable()
        
        return nameOverlap
    }
    
}

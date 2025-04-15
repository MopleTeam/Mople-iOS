//
//  ProfileViewReactor.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import ReactorKit

final class ProfileViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum Flow {
            case editProfile
            case setNotify
            case policy
            case logout
        }
        
        case flow(Flow)
        case fetchUserInfo
        case deleteAccount
    }
    
    enum Mutation {
        case fetchUserInfo(_ userInfo: UserInfo)
    }
    
    struct State {
        @Pulse var userProfile: UserInfo?
    }
    
    // MARK: - Variables
    var initialState = State()
    
    // MARK: - Coordinator
    private weak var coordinator: ProfileCoordination?
    
    // MARK: - LifeCycle
    init(coordinator: ProfileCoordination) {
        self.coordinator = coordinator
        action.onNext(.fetchUserInfo)
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchUserInfo:
            return fetchProfile()
        case let .flow(action):
            return handleFlowAction(action)
        case .deleteAccount:
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .fetchUserInfo(let profile):
            newState.userProfile = profile
        }
        
        return newState
    }
    
}

// MARK: - Data Request
extension ProfileViewReactor {
    
    private func fetchProfile() -> Observable<Mutation> {
        guard let userInfo = UserInfoStorage.shared.userInfo else { return .empty() }
        return .just(.fetchUserInfo(userInfo))
    }

}

// MARK: - Coordination
extension ProfileViewReactor {
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case .editProfile:
            guard let previousProfile = currentState.userProfile else { return .empty() }
            coordinator?.presentEditView(previousProfile: previousProfile)
        case .setNotify:
            coordinator?.pushNotifyView()
        case .policy:
            coordinator?.pushPolicyView()
        case .logout:
            coordinator?.logout()
        }
        return .empty()
    }
}

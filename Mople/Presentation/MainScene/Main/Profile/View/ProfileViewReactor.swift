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
    
    var initialState = State()
    
    private weak var coordinator: ProfileCoordination?
    
    init(coordinator: ProfileCoordination) {
        self.coordinator = coordinator
        action.onNext(.fetchUserInfo)
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
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

extension ProfileViewReactor {
    
    private func fetchProfile() -> Observable<Mutation> {
        guard let userInfo = UserInfoStorage.shared.userInfo else { return .empty() }
        return .just(.fetchUserInfo(userInfo))
    }

}

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

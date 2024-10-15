//
//  ProfileViewReactor.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import ReactorKit

struct accountAction {
    var editProfile: (Profile) -> Void
}

final class ProfileViewReactor: Reactor {
    
    enum Action {
        case fetchProfile
        case editProfile(_ profile: Profile)
        case notifyManagement
        case personalInfo
        case logout
        case deleteAccount
    }
    
    enum Mutation {
        case loadedProfile(profile: ProfileInfo)
    }
    
    struct State {
        @Pulse var userProfile: ProfileInfo?
    }
    
    var initialState = State()
    
    var editProfileUseCase: EditProfile
    var accountAction: accountAction
    
    init(editProfileUseCase: EditProfile,
         accountAction: accountAction) {
        self.editProfileUseCase = editProfileUseCase
        self.accountAction = accountAction
        action.onNext(.fetchProfile)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchProfile:
            return self.getProfile()
        case .editProfile(let profile):
            return presentEditView(profile)
        case .notifyManagement:
            return Observable.empty()
        case .personalInfo:
            return Observable.empty()
        case .logout:
            return Observable.empty()
        case .deleteAccount:
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadedProfile(let profile):
            newState.userProfile = profile
        }
        
        return newState
    }
    
}

extension ProfileViewReactor {
    private func getProfile() -> Observable<Mutation> {
        return editProfileUseCase.fetchProfile()
            .asObservable()
            .map { Mutation.loadedProfile(profile: $0) }
    }
    
    private func presentEditView(_ profile: Profile) -> Observable<Mutation> {
        accountAction.editProfile(profile)
        
        return Observable.empty()
    }
}

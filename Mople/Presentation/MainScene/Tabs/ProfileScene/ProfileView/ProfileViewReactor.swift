//
//  ProfileViewReactor.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import ReactorKit

struct ProfileUpdateModel {
    var currentProfile: UserInfo
    var completedAction: () -> Void
}

final class ProfileViewReactor: Reactor {
    
    enum Action {
        case fetchProfile
        case editProfile
        case presentNotifyView
        case presentPolicyView
        case logout
        case deleteAccount
    }
    
    enum Mutation {
        case loadedProfile(profile: UserInfo)
    }
    
    struct State {
        @Pulse var userProfile: UserInfo?
    }
    
    var initialState = State()
    
    private let fetchProfileIUseCase: FetchProfile
    private weak var coordinator: ProfileCoordination?
    
    init(fetchProfileIUseCase: FetchProfile,
         coordinator: ProfileCoordination) {
        print(#function, #line, "LifeCycle Test ProfileView Reactor Created" )
        self.fetchProfileIUseCase = fetchProfileIUseCase
        self.coordinator = coordinator
        action.onNext(.fetchProfile)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test ProfileView Reactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchProfile:
            return self.getProfile()
        case .editProfile:
            return presentEditView()
        case .presentNotifyView:
            return presentNotifyView()
        case .presentPolicyView:
            return presentPolicyView()
        case .logout:
            return self.logout()
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
        return fetchProfileIUseCase.fetchProfile()
            .asObservable()
            .map { Mutation.loadedProfile(profile: $0) }
    }
    
    private func presentEditView() -> Observable<Mutation> {
        guard let previousProfile = currentState.userProfile else { return .empty() }
        coordinator?.presentEditView(previousProfile: previousProfile)
        return Observable.empty()
    }
    
    /// 코디네이터에게 알림관리 뷰로 이동요청
    private func presentNotifyView() -> Observable<Mutation> {
        coordinator?.presentNotifyView()
        return Observable.empty()
    }
    
    /// 코디네이터에게 개인정보 처리방침 뷰로 이동요청
    private func presentPolicyView() -> Observable<Mutation> {
        coordinator?.presentPolicyView()
        return Observable.empty()
    }
    
    /// 로그아웃시 키체인에 저장된 토큰정보 삭제 후 로그인 화면으로 이동
    private func logout() -> Observable<Mutation> {
        KeyChainService.shared.deleteToken()
        coordinator?.logout()
        return Observable.empty()
    }
}

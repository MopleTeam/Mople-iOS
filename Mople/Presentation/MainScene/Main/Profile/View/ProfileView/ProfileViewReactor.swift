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
        case fetchUserInfo
        case editProfile
        case presentNotifyView
        case presentPolicyView
        case logout
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
            return self.fetchProfile()
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
        case .fetchUserInfo(let profile):
            newState.userProfile = profile
        }
        
        return newState
    }
    
}

extension ProfileViewReactor {
    
    #warning("프로필 없는 경우(?) 처리")
    private func fetchProfile() -> Observable<Mutation> {
        guard let userInfo = UserInfoStorage.shared.userInfo else { return .empty() }
        return .just(.fetchUserInfo(userInfo))
    }
    
    private func presentEditView() -> Observable<Mutation> {
        guard let previousProfile = currentState.userProfile else { return .empty() }
        coordinator?.presentEditView(previousProfile: previousProfile)
        return Observable.empty()
    }
    
    /// 코디네이터에게 알림관리 뷰로 이동요청
    private func presentNotifyView() -> Observable<Mutation> {
        coordinator?.pushNotifyView()
        return Observable.empty()
    }
    
    /// 코디네이터에게 개인정보 처리방침 뷰로 이동요청
    private func presentPolicyView() -> Observable<Mutation> {
        coordinator?.pushPolicyView()
        return Observable.empty()
    }
    
    /// 로그아웃시 키체인에 저장된 토큰정보 삭제 후 로그인 화면으로 이동
    private func logout() -> Observable<Mutation> {
        self.coordinator?.logout()
        return .empty()
    }
}

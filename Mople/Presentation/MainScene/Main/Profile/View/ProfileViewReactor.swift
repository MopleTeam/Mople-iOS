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
            case endMainFlow
        }
        
        case flow(Flow)
        case fetchUserInfo
        case signOut
        case deleteAccount
    }
    
    enum Mutation {
        case fetchUserInfo(_ userInfo: UserInfo)
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var userProfile: UserInfo?
        @Pulse var isLoading: Bool = false
        @Pulse var error: Error?
    }
    
    // MARK: - Variables
    var initialState = State()
    private var userId: Int?
    private var isRequesting: Bool = false
    
    // MARK: - UseCase
    private let signOutUseCase: SignOut
    private let deleteAccountUseCase: DeleteAccount
    
    // MARK: - Coordinator
    private weak var coordinator: ProfileCoordination?
    
    // MARK: - LifeCycle
    init(signOutUseCase: SignOut,
         deleteAccountUseCase: DeleteAccount,
         coordinator: ProfileCoordination) {
        self.signOutUseCase = signOutUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
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
        case .signOut:
            return signOut()
        case .deleteAccount:
            return deleteAccount()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .fetchUserInfo(let profile):
            newState.userProfile = profile
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
    
}

// MARK: - Data Request
extension ProfileViewReactor {
    
    private func fetchProfile() -> Observable<Mutation> {
        guard let userInfo = UserInfoStorage.shared.userInfo else { return .empty() }
        userId = userInfo.id
        return .just(.fetchUserInfo(userInfo))
    }
    
    private func signOut() -> Observable<Mutation> {
        guard let userId = UserInfoStorage.shared.userInfo?.id,
              !isRequesting else { return .empty() }
        
        isRequesting = true
        
        let signOut = signOutUseCase.execute(userId: userId)
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                self?.resetUserData()
                self?.coordinator?.endMainFlow()
                return .empty()
            }
        
        return requestWithLoading(task: signOut)
            .do(onDispose: { [weak self] in
                self?.isRequesting = false
            })
    }
    
    private func deleteAccount() -> Observable<Mutation> {
        guard !isRequesting else { return .empty() }
        
        isRequesting = true
        
        let deleteAccount = deleteAccountUseCase.execute()
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                self?.resetUserData()
                self?.coordinator?.endMainFlow()
                return .empty()
            }
        
        return requestWithLoading(task: deleteAccount)
            .do(onDispose: { [weak self] in
                self?.isRequesting = false
            })
    }
    
    private func resetUserData() {
        KeychainStorage.shared.deleteToken()
        UserInfoStorage.shared.deleteEnitity()
        UserDefaults.deleteFCMToken()
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
        case .endMainFlow:
            resetUserData()
            coordinator?.endMainFlow()
        }
        return .empty()
    }
}

extension ProfileViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}

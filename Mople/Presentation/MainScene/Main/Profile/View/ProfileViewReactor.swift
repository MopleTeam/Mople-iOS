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
            case showProfileImage
            case editProfile
            case setNotify
            case policy
            case showTransferMeetList(meets: [Meet])  // 양도할 모임 리스트 전달
            case endMainFlow
        }
        
        case flow(Flow)
        case fetchUserInfo
        case signOut
        case checkMeetsBeforeDelete  // 탈퇴 전 모임 체크
        case deleteAccount  // 실제 탈퇴 실행
    }
    
    enum Mutation {
        case fetchUserInfo(_ userInfo: UserInfo)
        case checkDeleteAccount
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var userProfile: UserInfo?
        @Pulse var deleteAccountAlert: Void?
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
    private let fetchMyHostMeetsUseCase: FetchMyHostMeets
    
    // MARK: - Coordinator
    private weak var coordinator: ProfileCoordination?
    
    // MARK: - LifeCycle
    init(signOutUseCase: SignOut,
         deleteAccountUseCase: DeleteAccount,
         fetchMyHostMeetsUseCase: FetchMyHostMeets,
         coordinator: ProfileCoordination) {
        self.signOutUseCase = signOutUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
        self.fetchMyHostMeetsUseCase = fetchMyHostMeetsUseCase
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
        case .checkMeetsBeforeDelete:
            return checkMeetsBeforeDelete()
        case .deleteAccount:
            return deleteAccount()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .fetchUserInfo(let profile):
            newState.userProfile = profile
        case .checkDeleteAccount:
            newState.deleteAccountAlert = ()
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
    
    private func checkMeetsBeforeDelete() -> Observable<Mutation> {
        guard !isRequesting else { return .empty() }
        
        isRequesting = true
        
        // 내가 호스트인 모임 리스트 조회
        let checkMeets = fetchMyHostMeetsUseCase.execute(cursor: nil)
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] page -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                                
                // 멤버가 2명 이상인 모임만 필터링 (양도 필요한 모임)
                let transferableMeets = page.content.filter { meet in
                    guard let memberCount = meet.memberCount else { return false }
                    return memberCount >= 2
                }
                
                if transferableMeets.isEmpty {
                    // 양도할 모임 없음 → 바로 탈퇴 진행
                    print("✅ 양도할 모임 없음 → 탈퇴 진행")
//                    return Observable.just(.checkDeleteAccount)
                    return .empty()
                } else {
                    // 양도할 모임 있음 → 양도 화면으로 이동
                    print("📋 양도할 모임 \(transferableMeets.count)개 → 양도 화면 이동")
                    self.coordinator?.showTransferMeetList()
                    return .empty()
                }
            }
        
        return requestWithLoading(task: checkMeets)
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
        case .showProfileImage:
            let profileImagePath = currentState.userProfile?.imagePath
            coordinator?.presentProfileImageView(imagePath: profileImagePath)
        case .editProfile:
            guard let previousProfile = currentState.userProfile else { return .empty() }
            coordinator?.presentEditView(previousProfile: previousProfile)
        case .setNotify:
            coordinator?.pushNotifyView()
        case .policy:
            coordinator?.pushPolicyView()
        case .showTransferMeetList:
            coordinator?.showTransferMeetList()
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

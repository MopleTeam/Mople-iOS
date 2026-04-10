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
            case setTheme
            case policy
            case endMainFlow
        }

        case flow(Flow)
        case fetchUserInfo
        case signOut
        case checkTransferMeet
        case deleteAccount   
    }

    enum Mutation {
        case fetchUserInfo(_ userInfo: UserInfo)
        case showDeleteConfirm
        case updateLoadingState(Bool)
        case catchError(Error)
    }

    struct State {
        @Pulse var userProfile: UserInfo?
        @Pulse var shouldShowDeleteConfirm: Void?
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
        case .checkTransferMeet:
            return checkTransferMeet()
        case .deleteAccount:
            return deleteAccount()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .fetchUserInfo(let profile):
            newState.userProfile = profile
        case .showDeleteConfirm:
            newState.shouldShowDeleteConfirm = ()
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

    /// 로그아웃 처리 (async → Observable 브릿지)
    private func signOut() -> Observable<Mutation> {
        guard let userId = UserInfoStorage.shared.userInfo?.id,
              !isRequesting else { return .empty() }

        isRequesting = true

        let signOut = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    try await self?.signOutUseCase.execute(userId: userId)
                    await MainActor.run {
                        self?.resetUserData()
                        self?.coordinator?.endMainFlow()
                    }
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }

        return requestWithLoading(task: signOut)
            .do(onDispose: { [weak self] in
                self?.isRequesting = false
            })
    }

  
    /// 양도 필요 모임 확인 (async → Observable 브릿지)
    private func checkTransferMeet() -> Observable<Mutation> {
        guard !isRequesting else { return .empty() }

        isRequesting = true

        let task = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    let page = try await self?.fetchMyHostMeetsUseCase.execute(cursor: nil)
                    await MainActor.run {
                        guard let self, let page else {
                            observer.onCompleted()
                            return
                        }

                        // 멤버가 2명 이상인 모임만 필터링 (양도 필요한 모임)
                        let transferableMeets = page.content.filter { meet in
                            guard let memberCount = meet.memberCount else { return false }
                            return memberCount >= 2
                        }

                        if transferableMeets.isEmpty {
                            // 양도할 모임 없음 → 탈퇴 확인 알림 표시
                            observer.onNext(.showDeleteConfirm)
                        } else {
                            // 양도할 모임 있음 → 양도 화면으로 이동
                            self.coordinator?.showTransferMeetList()
                        }
                        observer.onCompleted()
                    }
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }

        return requestWithLoading(task: task)
            .do(onDispose: { [weak self] in
                self?.isRequesting = false
            })
    }

    /// 계정 삭제 처리 (async → Observable 브릿지)
    private func deleteAccount() -> Observable<Mutation> {
        guard !isRequesting else { return .empty() }

        isRequesting = true

        let deleteAccount = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    try await self?.deleteAccountUseCase.execute()
                    await MainActor.run {
                        self?.resetUserData()
                        self?.coordinator?.endMainFlow()
                    }
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
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
        case .setTheme:
            coordinator?.presentThemeView()
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

//
//  MainTabBarReactor.swift
//  Mople
//
//  Created by CatSlave on 4/23/25.
//

import UIKit
import ReactorKit

final class MainTabBarReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case checkNotificationPermission
        case joinMeet(code: String)
        case resetNotify
    }
    
    enum Mutation {
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var isLoading: Bool?
        @Pulse var error: Error?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let isLogin: Bool
    private var isRequesting: Bool = false
    
    // MARK: - UseCcase
    private let uploadFCMTokenUseCase: UploadFCMToken
    private let joinMeetUseCae: JoinMeet
    private let resetNotifyCountUseCase : ResetNotifyCount
    
    // MARK: - Notification
    private let notificationService: NotificationService
    
    // MARK: - Coordinator
    private weak var coordinator: MainCoordination?
    
    // MARK: - LifeCycle
    init(isLogin: Bool,
         uploadFCMTokcnUseCase: UploadFCMToken,
         joinMeetUseCase: JoinMeet,
         resetNotifyCountUseCase: ResetNotifyCount,
         notificationService: NotificationService,
         coordinator: MainCoordination) {
        self.isLogin = isLogin
        self.uploadFCMTokenUseCase = uploadFCMTokcnUseCase
        self.resetNotifyCountUseCase = resetNotifyCountUseCase
        self.joinMeetUseCae = joinMeetUseCase
        self.notificationService = notificationService
        self.coordinator = coordinator
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkNotificationPermission:
            return requestNotificationPermission()
        case let .joinMeet(code):
            return requestJoinMeet(code: code)
        case .resetNotify:
            return requestResetNotify()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}


// MARK: - Permission
extension MainTabBarReactor {
    private func requestNotificationPermission() -> Observable<Mutation> {
        return notificationService.requestPermissions()
            .flatMap { [weak self] isAllow -> Observable<Mutation> in
                guard let self,
                      isAllow else { return .empty() }
                return uploadFCMToken()
            }
            .debug("토큰 업로드 스트림")
    }
    
    private func uploadFCMToken() -> Observable<Mutation> {
        let uploadToken = uploadFCMTokenUseCase.execute()
            .flatMap { _ -> Observable<Mutation> in
                return .empty()
            }
        return requestWithLoading(task: uploadToken)
    }
}

// MARK: - Handle Join Meet
extension MainTabBarReactor {
    private func requestJoinMeet(code: String) -> Observable<Mutation> {
        guard !isRequesting else { return .empty() }
        isRequesting = true
        
        let joinMeet = joinMeetUseCae.execute(code: code)
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { [weak self] meet -> Observable<Mutation> in
                guard let self else { return .empty() }
                postAddMeet(with: meet)
                coordinator?.showJoinedMeet(with: meet)
                return .empty()
            }
        
        return requestWithLoading(task: joinMeet)
            .do(onDispose: { [weak self] in
                self?.isRequesting = false
            })
    }
    
    private func postAddMeet(with meet: Meet) {
        NotificationManager.shared.postItem(.created(meet), from: self)
    }
}

// MARK: - Reset Notify Count
extension MainTabBarReactor {
    private func requestResetNotify() -> Observable<Mutation> {
        return resetNotifyCountUseCase.execute()
            .flatMap { _ -> Observable<Mutation> in
                return .empty()
            }
    }
}

extension MainTabBarReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}

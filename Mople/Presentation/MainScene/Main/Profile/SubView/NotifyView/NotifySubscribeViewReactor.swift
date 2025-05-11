//
//  NotifySubscribeViewReactor.swift
//  Mople
//
//  Created by CatSlave on 4/11/25.
//

import ReactorKit

enum SubscribeType: String {
    case meet = "MEET"
    case plan = "PLAN"
}

protocol NotifySubscribeCoordination: NavigationCloseable { }

final class NotifySubscribeViewReactor: Reactor {
    
    enum Action {
        case checkNotification
        case updateNotification
        case fetchSubscribeState
        case subscribe(type: SubscribeType,
                       isSubscribe: Bool)
        case endFlow
    }
    
    enum Mutation {
        case updateSubscribes(Set<SubscribeType>)
        case updateLoadingState(Bool)
        case updatePermissions(isAllow: Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var isAllowPermissions: Bool?
        @Pulse var subscribes: Set<SubscribeType> = .init()
        @Pulse var error: Error?
        @Pulse var isLoading: Bool = false
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var requestType: SubscribeType?
    private var isRequesting: Bool = false
    
    // MARK: - UseCase
    private let fetchNotifyStateUseCase: FetchNotifyState
    private let subscribeNotifyUseCase: SubscribeNotify
    private let uploadFCMTokenUseCase: UploadFCMToken
    
    // MARK: - Coordinator
    private weak var coordinator: NotifySubscribeCoordination?
    
    // MARK: - Notification
    private let notificationService: NotificationService
    
    init(fetchNotifyState: FetchNotifyState,
         subscribeNotify: SubscribeNotify,
         uploadFCMTokcn: UploadFCMToken,
         notificationService: NotificationService,
         coordinator: NotifySubscribeCoordination) {
        self.fetchNotifyStateUseCase = fetchNotifyState
        self.subscribeNotifyUseCase = subscribeNotify
        self.uploadFCMTokenUseCase = uploadFCMTokcn
        self.notificationService = notificationService
        self.coordinator = coordinator
        initialAction()
    }
    
    // MARK: - Initial Setup
    private func initialAction() {
        action.onNext(.checkNotification)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkNotification:
            return checkPermissions()
        case .updateNotification:
            return updatePermissions()
        case .fetchSubscribeState:
            return fetchNotifyState()
        case let .subscribe(type, isSubscribe):
            return requestSubscribe(type: type,
                                    isSubscribe: isSubscribe)
        case .endFlow:
            return endFlow()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updatePermissions(isAllow):
            newState.isAllowPermissions = isAllow
        case let .updateSubscribes(subscribes):
            newState.subscribes = subscribes
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
    
}

// MARK: - Check Permissions
extension NotifySubscribeViewReactor {
    private func checkPermissions() -> Observable<Mutation> {
        return notificationService.checkNotifyPermissions()
            .flatMap { [weak self] isAllow -> Observable<Mutation> in
                guard let self else { return .empty() }
                let updatePremissionState = Mutation.updatePermissions(isAllow: isAllow)
                
                if isAllow {
                    return .concat(Observable.just(updatePremissionState),
                                   fetchNotifyState())
                } else {
                    return Observable.just(updatePremissionState)
                }
            }
    }
    
    private func updatePermissions() -> Observable<Mutation> {
        return notificationService.checkNotifyPermissions()
            .flatMap { [weak self] isAllow -> Observable<Mutation> in
                guard let self else { return .empty() }
                let permissionState = Mutation.updatePermissions(isAllow: isAllow)
                let updatePermissionState = Observable.just(permissionState)

                if isAllow {
                    return .concat(updateNotifyState(),
                                   updatePermissionState)
                } else {
                    return updatePermissionState
                }
            }
    }
    
    private func updateNotifyState() -> Observable<Mutation> {
        let uploadFCMToken = uploadFCMTokenUseCase.execute()
            .flatMap { [weak self] _ -> Observable<[SubscribeType]> in
                guard let self else { return .empty() }
                return fetchNotifyStateUseCase.execute()
            }
            .map { Mutation.updateSubscribes(Set($0)) }
        
        return requestWithLoading(task: uploadFCMToken)
    }
}

// MARK: - Data Request
extension NotifySubscribeViewReactor {
    private func fetchNotifyState() -> Observable<Mutation> {
        let fetchState = fetchNotifyStateUseCase.execute()
            .map { Mutation.updateSubscribes(Set($0)) }
        
        return requestWithLoading(task: fetchState)
    }
    
    private func requestSubscribe(type: SubscribeType,
                                  isSubscribe: Bool) -> Observable<Mutation> {
        guard !isRequesting else { return .empty() }
        
        isRequesting = true
        
        let requsetSubscribe = subscribeNotifyUseCase.execute(type: type,
                                                              isSubscribe: isSubscribe)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self else { return .empty() }
                let changeSubscribe = changeSubscribe(type: type,
                                                      isSubscribe: isSubscribe)
                return .just(.updateSubscribes(changeSubscribe))
            }
        
        return requestWithLoading(task: requsetSubscribe)
            .do(onDispose: { [weak self] in
                self?.isRequesting = false
            })
    }
    
    private func changeSubscribe(type: SubscribeType,
                                 isSubscribe: Bool) -> Set<SubscribeType> {
        var currentSubscribe = currentState.subscribes
        
        if isSubscribe {
            currentSubscribe.insert(type)
        } else {
            currentSubscribe.remove(type)
        }
        
        return currentSubscribe
    }
}

// MARK: - Coordination
extension NotifySubscribeViewReactor {
    private func endFlow() -> Observable<Mutation> {
        coordinator?.pop()
        return .empty()
    }
}

// MARK: - Loading & Error
extension NotifySubscribeViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}

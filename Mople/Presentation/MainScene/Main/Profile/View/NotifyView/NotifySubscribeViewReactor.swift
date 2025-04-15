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
        case fetchSubscribeState
        case subscribe(type: SubscribeType,
                       isSubscribe: Bool)
        case endFlow
    }
    
    enum Mutation {
        case updateSubscribes(Set<SubscribeType>)
        case updateLoadingState(Bool)
        case updatePremissions(isAllow: Bool)
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
    
    // MARK: - UseCase
    private let fetchNotifyStateUseCase: FetchNotifyState
    private let subscribeNotifyUseCase: SubscribeNotify
    
    // MARK: - Coordinator
    private weak var coordinator: NotifySubscribeCoordination?
    
    // MARK: - Notification
    private let notificationService: NotificationService
    
    init(fetchNotifyState: FetchNotifyState,
         subscribeNotify: SubscribeNotify,
         notificationService: NotificationService,
         coordinator: NotifySubscribeCoordination) {
        self.fetchNotifyStateUseCase = fetchNotifyState
        self.subscribeNotifyUseCase = subscribeNotify
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
        case let .updatePremissions(isAllow):
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
        
        return notificationService.checkPrePermissions()
            .flatMap { [weak self] isAllow -> Observable<Mutation> in
                guard let self else { return .empty() }
                let updatePremissionState = Mutation.updatePremissions(isAllow: isAllow)
                
                if isAllow {
                    return .concat(Observable.just(updatePremissionState),
                                   fetchNotifyState())
                } else {
                    return Observable.just(updatePremissionState)
                }
            }
    }
}

// MARK: - Data Request
extension NotifySubscribeViewReactor {
    private func fetchNotifyState() -> Observable<Mutation> {
        let fetchState = fetchNotifyStateUseCase.execute()
            .asObservable()
            .map { Mutation.updateSubscribes(Set($0)) }
        
        return requestWithLoading(task: fetchState)
    }
    
    private func requestSubscribe(type: SubscribeType,
                                  isSubscribe: Bool) -> Observable<Mutation> {
        
        let requsetSubscribe = subscribeNotifyUseCase.execute(type: type,
                                                              isSubscribe: isSubscribe)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self else { return .empty() }
                let changeSubscribe = changeSubscribe(type: type,
                                                      isSubscribe: isSubscribe)
                return .just(.updateSubscribes(changeSubscribe))
            }
        
        return requestWithLoading(task: requsetSubscribe)
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

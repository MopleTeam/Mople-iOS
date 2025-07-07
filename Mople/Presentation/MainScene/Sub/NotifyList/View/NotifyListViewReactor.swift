//
//  NotifyViewReactor.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import ReactorKit

final class NotifyListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum Flow {
            case selectNotify(index: Int)
            case endFlow
        }
        
        case flow(Flow)
        case fetchNotifyList
        case refresh
    }
    
    enum Mutation {
        case updateNotifyList([Notify])
        case completedRefresh
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var notifyList: [Notify] = []
        @Pulse var isRefreshed: Void?
        @Pulse var isLoading: Bool = false
        @Pulse var error: Error?
    }
    
    var initialState: State = State()
    
    // MARK: - UseCase
    private let fetchNotifyListUseCase: FetchNotifyList
    private let resetNotifyCountUseCase : ResetNotifyCount
    
    // MARK: - Coordinator
    private weak var coordinator: NotifyListFlowCoordination?
    
    // MARK: - LifeCycle
    init(fetchNotifyList: FetchNotifyList,
         resetNotifyCount: ResetNotifyCount,
         coordinator: NotifyListFlowCoordination) {
        self.fetchNotifyListUseCase = fetchNotifyList
        self.resetNotifyCountUseCase = resetNotifyCount
        self.coordinator = coordinator
        initialAction()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Intial Setup
    private func initialAction() {
        action.onNext(.fetchNotifyList)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchNotifyList:
            return fetchNotifyWithLoading()
        case let .flow(action):
            return handleFlowAction(action)
        case .refresh:
            return refreshNotify()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateNotifyList(notifyList):
            newState.notifyList = notifyList
        case .completedRefresh:
            newState.isRefreshed = ()
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}

// MARK: - Data Requset
extension NotifyListViewReactor {
    private func fetchNotify() -> Observable<Mutation> {
        return fetchNotifyListUseCase.execute()
            .map { Mutation.updateNotifyList($0) }
            .concat(resetNotifyCount())
    }
    
    private func fetchNotifyWithLoading() -> Observable<Mutation> {
        return requestWithLoading(task: fetchNotify())
            .concat(resetNotifyCount())
    }
    
    private func resetNotifyCount() -> Observable<Mutation> {
        return resetNotifyCountUseCase.execute()
            .flatMap { _ -> Observable<Mutation> in
                return .empty()
            }
    }

    private func refreshNotify() -> Observable<Mutation> {
        return .concat([fetchNotify(),
                        .just(Mutation.completedRefresh)])
    }
}

// MARK: - Coordination 
extension NotifyListViewReactor {
    
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            return endFlow()
        case let .selectNotify(index):
            return handleSelectedNotify(index: index)
        }
    }
    
    private func endFlow() -> Observable<Mutation> {
        coordinator?.endFlow()
        return .empty()
    }
    
    
    private func handleSelectedNotify(index: Int) -> Observable<Mutation> {
        guard let selectedType = currentState.notifyList[safe: index]?.type else {
            return .empty()
        }
        
        return handleNotifyFlowAction(type: selectedType)
    }
    
    private func handleNotifyFlowAction(type: NotifyType) -> Observable<Mutation> {
        switch type {
        case let .meet(id):
            coordinator?.presentMeetDetailView(meetId: id)
        case let .plan(id):
            coordinator?.presentPlanDetailView(postId: id,
                                               type: .plan)
        case let .review(id):
            coordinator?.presentPlanDetailView(postId: id,
                                               type: .review)
        }
        
        return .empty()
    }
}

// MARK: - Loading & Error
extension NotifyListViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}

//
//  NotifyViewReactor.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import ReactorKit

final class NotifyListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case fetchNotifyList
        case selectNotify(index: Int)
        case endFlow
    }
    
    enum Mutation {
        case updateNotifyList([Notify])
        case resetNotifyCount
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var notifyList: [Notify] = []
        @Pulse var resetedCount: Void?
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
            return fetchNotifyAndResetCount()
        case let .selectNotify(index):
            return handleNotifyTap(index: index)
        case .endFlow:
            coordinator?.endFlow()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateNotifyList(notifyList):
            print(#function, #line, "Path : # 알림 리스트 조정 ")
            newState.notifyList = notifyList
        case .resetNotifyCount:
            print(#function, #line, "Path : # 알림 리셋 조정 ")
            newState.resetedCount = ()
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
    private func fetchNotifyAndResetCount() -> Observable<Mutation> {

        let fetchNotify = fetchNotifyListUseCase.execute()
            .asObservable()
            .flatMap({ [weak self] notifyList -> Observable<Mutation> in
                guard let self else { return .empty() }
                
                return resetNotifyCountUseCase.execute()
                    .asObservable()
                    .map { _ in Mutation.updateNotifyList(notifyList) }
            })
        
        return requestWithLoading(task: fetchNotify)
            .concat(Observable<Mutation>.just(.resetNotifyCount))
    }
}

// MARK: - Coordination 
extension NotifyListViewReactor {
    private func handleNotifyTap(index: Int) -> Observable<Mutation> {
        let currentNotify = currentState.notifyList
        
        guard let selectNotify = currentNotify[safe: index],
              let notifyType = selectNotify.type else { return .empty() }
        handleRouting(type: notifyType)
        return .empty()
    }
    
    private func handleRouting(type: NotifyType) {
        print(#function, #line, "#0411 : \(type)" )
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

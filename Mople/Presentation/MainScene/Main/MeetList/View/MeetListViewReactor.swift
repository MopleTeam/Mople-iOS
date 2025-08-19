//
//  GroupListViewReactor.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import ReactorKit

final class MeetListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum Flow {
            case showJoinMeet(Meet)
            case selectMeet(index: Int)
            case createMeet
        }
        
        case flow(Flow)
        case updateMeet(_ meetPayload: MeetPayload)
        case fetchMeet
        case fetchNextMeet
        case refresh
    }
    
    enum Mutation {
        case fetchMeetList([Meet])
        case completedRefresh
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var meetList: [Meet] = []
        @Pulse var isRefreshed: Void?
        @Pulse var isLoading: Bool = false
        @Pulse var error: Error?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private(set) var page: PageInfo?
    private var isLoading: Bool = false
    
    // MARK: - UseCase
    private let fetchUseCase: FetchMeetPage
    
    // MARK: - Coordinator
    private weak var coordinator: MeetListFlowCoordination?
    
    // MARK: - LifeCycle
    init(fetchUseCase: FetchMeetPage,
         coordinator: MeetListFlowCoordination) {
        self.fetchUseCase = fetchUseCase
        self.coordinator = coordinator
        initialAction()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - InitialSetup
    private func initialAction() {
        action.onNext(.fetchMeet)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        guard shouldAction(action) else { return .empty() }
        switch action {
        case .fetchMeet:
            return fetchMeetListWithLoading()
        case .fetchNextMeet:
            return fetchNextPage()
        case .refresh:
            return refresh()
        case let .flow(action):
            return handleFlowAction(action)
        case let .updateMeet(meet):
            return self.handleMeetPayload(meet)
        }
    }
    
    private func shouldAction(_ action: Action) -> Bool {
        switch action {
        case .fetchMeet, .fetchNextMeet, .refresh:
            return !isLoading
        default:
            return true
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .fetchMeetList(meetList):
            newState.meetList = meetList
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

// MARK: - Data Request
extension MeetListViewReactor {
    
    /// 모임 리스트 불러오기
    private func fetchMeetList(cursor: String? = nil,
                               isRefresh: Bool = false) -> Observable<Mutation> {
        return fetchUseCase.execute(cursor: cursor)
            .map({ result in
                self.page = result.info
                return self.updateMeetList(isRefresh: isRefresh, meets: result.content)
            })
    }
    
    /// 모임 리스트 로딩과 함께 불러오기
    private func fetchMeetListWithLoading(cursor: String? = nil) -> Observable<Mutation> {
        let fetchData = fetchMeetList(cursor: cursor)
        return requestWithLoading(task: fetchData)
    }
    
    private func fetchNextPage() -> Observable<Mutation> {
        guard let cursor = page?.nextCursor else { return .empty() }
        return fetchMeetListWithLoading(cursor: cursor)
    }
    
    private func refresh() -> Observable<Mutation> {
        return fetchMeetList(isRefresh: true)
            .concat(Observable.just(.completedRefresh))
    }
    
    private func updateMeetList(isRefresh: Bool, meets: [Meet]) -> Mutation {
        var newMeets = currentState.meetList
        if isRefresh {
            newMeets = meets
        } else {
            newMeets.append(contentsOf: meets)
        }
        return .fetchMeetList(newMeets)
    }
}

// MARK: - Coordination
extension MeetListViewReactor {
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case let .showJoinMeet(meet):
            presentJoinMeet(with: meet)
        case let .selectMeet(index):
            presentSelectedMeet(index: index)
        case .createMeet:
            coordinator?.presentMeetCreateView()
        }
        
        return .empty()
    }
    
    private func presentSelectedMeet(index: Int) {
        guard let selectedGroup = currentState.meetList[safe: index],
              let id = selectedGroup.meetSummary?.id else { return  }
        coordinator?.presentMeetDetailView(meetId: id, isJoin: false)
    }
    
    private func presentJoinMeet(with meet: Meet) {
        guard let meetId = meet.meetSummary?.id else { return }
        coordinator?.presentMeetDetailView(meetId: meetId, isJoin: true)
    }
}


// MARK: - Notify
extension MeetListViewReactor {
    private func handleMeetPayload(_ payload: MeetPayload) -> Observable<Mutation> {
        
        var meetList = currentState.meetList
        
        switch payload {
        case let .created(meet):
            self.addMeet(&meetList, meet: meet)
        case let .updated(meet):
            self.updatedMeet(&meetList, meet: meet)
        case let .deleted(id):
            self.deleteMeet(&meetList, meetId: id)
        }
        return .just(.fetchMeetList(meetList))
    }
    
    private func addMeet(_ meetList: inout [Meet], meet: Meet) {
        meetList.append(meet)
    }
    
    private func updatedMeet(_ meetList: inout [Meet], meet: Meet) {
        guard let updatedMeetIndex = meetList.firstIndex(where: {
            $0.meetSummary?.id == meet.meetSummary?.id
        }) else { return }
        
        meetList[updatedMeetIndex] = meet
    }
    
    private func deleteMeet(_ meetList: inout [Meet], meetId: Int) {
        meetList.removeAll { $0.meetSummary?.id == meetId }
    }
}

// MARK: - Loading & Error
extension MeetListViewReactor: LoadingReactor {
    func updateLoadingState(isLoad: Bool) {
        isLoading = isLoad
    }
    
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}

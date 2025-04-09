//
//  GroupListViewReactor.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import ReactorKit

final class MeetListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case fetchMeetList
        case selectMeet(index: Int)
        case updateMeet(_ meetPayload: MeetPayload)
    }
    
    enum Mutation {
        case fetchMeetList([Meet])
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var meetList: [Meet] = []
        @Pulse var isLoading: Bool = false
        @Pulse var error: Error?
    }
    
    private let fetchUseCase: FetchMeetList
    private weak var coordinator: MeetListFlowCoordination?
    var initialState: State = State()
    
    init(fetchUseCase: FetchMeetList,
         coordinator: MeetListFlowCoordination) {
        self.fetchUseCase = fetchUseCase
        self.coordinator = coordinator
        action.onNext(.fetchMeetList)
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchMeetList:
            return fetchMeetList()
        case let .selectMeet(index):
            return presentMeetDetailView(index: index)
        case let .updateMeet(meet):
            return self.handleMeetPayload(meet)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .fetchMeetList(meetList):
            newState.meetList = meetList
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}


extension MeetListViewReactor {
    private func fetchMeetList() -> Observable<Mutation> {
        
        let fetchData = fetchUseCase.execute()
            .asObservable()
            .map { Mutation.fetchMeetList($0) }
        
        return requestWithLoading(task: fetchData)
    }
    
    private func presentMeetDetailView(index: Int) -> Observable<Mutation> {
        guard let selectedGroup = currentState.meetList[safe: index],
              let id = selectedGroup.meetSummary?.id else { return .empty() }
        coordinator?.presentMeetDetailView(meetId: id)
        return .empty()
    }
}

// MARK: - 노티피케이션
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
        meetList.insert(meet, at: 0)
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

extension MeetListViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}

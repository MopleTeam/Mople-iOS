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
    }
    
    enum Mutation {
        case fetchMeetList(groupList: [Meet])
    }
    
    struct State {
        @Pulse var meetList: [Meet] = []
    }
    
    private let fetchUseCase: FetchMeetList
    private let coordinator: MainCoordination
    var initialState: State = State()
    
    init(fetchUseCase: FetchMeetList,
         coordinator: MainCoordination) {
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
            fetchMeetList()
        case let .selectMeet(index):
            presentMeetDetailView(index: index)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .fetchMeetList(let groupList):
            newState.meetList = groupList
        }
        
        return newState
    }
}


extension MeetListViewReactor {
    private func fetchMeetList() -> Observable<Mutation> {
        
        let fetchData = fetchUseCase.fetchMeetList()
            .asObservable()
            .map { Mutation.fetchMeetList(groupList: $0) }
        
        return fetchData
    }
    
    private func presentMeetDetailView(index: Int) -> Observable<Mutation> {
        guard let selectedGroup = currentState.meetList[safe: index],
              let id = selectedGroup.meetSummary?.id else { return .empty() }
        coordinator.presentMeetDetailScene(meetId: id)
        return .empty()
    }
}

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
        case fetchMeetList(groupList: [Meet])
    }
    
    struct State {
        @Pulse var meetList: [Meet] = []
    }
    
    private let fetchUseCase: FetchMeetList
    private let coordinator: MeetListFlowCoordination
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
        case .fetchMeetList(let groupList):
            newState.meetList = groupList
        }
        
        return newState
    }
}


extension MeetListViewReactor {
    private func fetchMeetList() -> Observable<Mutation> {
        
        let fetchData = fetchUseCase.execute()
            .asObservable()
            .map { Mutation.fetchMeetList(groupList: $0) }
        
        return fetchData
    }
    
    private func presentMeetDetailView(index: Int) -> Observable<Mutation> {
        guard let selectedGroup = currentState.meetList[safe: index],
              let id = selectedGroup.meetSummary?.id else { return .empty() }
        coordinator.presentMeetDetailView(meetId: id)
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
        case let .deleted(meet):
            self.deleteMeet(&meetList, meet: meet)
        }
        return .just(.fetchMeetList(groupList: meetList))
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
    
    private func deleteMeet(_ meetList: inout [Meet], meet: Meet) {
        meetList.removeAll { $0.meetSummary?.id == meet.meetSummary?.id }
    }
}

//
//  GroupListViewReactor.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import ReactorKit

final class GroupListViewReactor: Reactor {
    enum Action {
        case fetchGroupList
    }
    
    enum Mutation {
        case fetchGroupList(groupList: [Group])
    }
    
    struct State {
        @Pulse var groupList: [Group] = []
    }
    
    private let fetchUseCase: FetchGroupList
    var initialState: State = State()
    
    init(fetchUseCase: FetchGroupList) {
        self.fetchUseCase = fetchUseCase
        action.onNext(.fetchGroupList)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchGroupList:
            return fetchGroupList()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .fetchGroupList(let groupList):
            newState.groupList = groupList
        }
        
        return newState
    }
}


extension GroupListViewReactor {
    private func fetchGroupList() -> Observable<Mutation> {
        
        let fetchData = fetchUseCase.fetchGroupList()
            .asObservable()
            .map { Mutation.fetchGroupList(groupList: $0) }
        
        return fetchData
    }
}

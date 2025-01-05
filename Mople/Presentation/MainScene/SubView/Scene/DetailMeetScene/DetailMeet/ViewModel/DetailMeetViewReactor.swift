//
//  DetailGroupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation
import ReactorKit

final class DetailMeetViewReactor: Reactor {
    
    enum Action {
        case testID(id: Int)
    }
    
    enum Mutation {
        case testID(id: Int)
    }
    
    struct State {
        // var property: TYpe
        @Pulse var id: Int?
    }
    
    var initialState: State = State()
    
    private let coordinator: DetailMeetCoordination
    
    init(coordinator: DetailMeetCoordination,
         groupID: Int) {
        self.coordinator = coordinator
        action.onNext(.testID(id: groupID))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .testID(id):
            return .just(.testID(id: id))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .testID(id):
            newState.id = id
        }
        
        return newState
    }
    
}


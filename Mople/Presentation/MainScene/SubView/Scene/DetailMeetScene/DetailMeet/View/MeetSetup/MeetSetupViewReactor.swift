//
//  MeetSetupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/8/25.
//

import Foundation
import ReactorKit

final class MeetSetupViewReactor: Reactor {
    
    enum Action {
        case setMeet(_ meet: Meet)
        case popView
    }
    
    enum Mutation {
        case updateMeet(_ meet: Meet)
    }
    
    struct State {
        @Pulse var meet: Meet?
    }
    
    var initialState: State = State()
    private weak var coordinator: DetailMeetCoordination?
    
    init(meet: Meet,
         coordinator: DetailMeetCoordination) {
        print(#function, #line, "LifeCycle Test MeetSetupViewReactor Created" )
        action.onNext(.setMeet(meet))
        self.coordinator = coordinator
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test MeetSetupViewReactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setMeet(Meet):
            return .just(.updateMeet(Meet))
        case .popView:
            coordinator?.popView()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateMeet(meet):
            newState.meet = meet
        }
        
        return newState
    }
    
}


//
//  GroupCreateViewReactor.swift
//  Group
//
//  Created by CatSlave on 11/18/24.
//

import UIKit
import ReactorKit

final class GroupCreateViewReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
    }
    
    struct State {
        // var property: TYpe
        // @Pulse var property: Type
    }
    
    var initialState: State = State()
    
    init() {
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        }
        
        return newState
    }
    
}


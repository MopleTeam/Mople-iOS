//
//  CommentListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import ReactorKit

final class CommentListViewReactor: Reactor {
    
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


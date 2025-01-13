//
//  PlanDetailViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import Foundation
import ReactorKit

final class PlanDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case updatePlanInfo(_ plan: Plan)
    }
    
    enum Mutation {
        case setPlanInfo(_ Plan: Plan)
    }
    
    struct State {
        @Pulse var plan: Plan?
    }
    
    var initialState: State = State()
    
    init(plan: Plan) {
        logLifeCycle()
        action.onNext(.updatePlanInfo(plan))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updatePlanInfo(plan):
            return .just(.setPlanInfo(plan))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .setPlanInfo(plan):
            newState.plan = plan
        }
        
        return newState
    }
    
}


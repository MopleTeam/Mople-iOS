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
        case updatePlanInfo(_ planId: Int)
    }
    
    enum Mutation {
        case setPlanInfo(_ Plan: Plan)
        case notifyLoadingState(_ isLoading: Bool)
        case notifyMessage(_ message: String)
    }
    
    struct State {
        @Pulse var plan: Plan?
        @Pulse var isLoading: Bool = false
        @Pulse var message: String?
    }
    
    private let fetchPlanDetailUsecase: FetchPlanDetail
    
    var initialState: State = State()
    
    init(planId: Int,
         fetchPlanDetailUseCase: FetchPlanDetail) {
        self.fetchPlanDetailUsecase = fetchPlanDetailUseCase
        logLifeCycle()
        action.onNext(.updatePlanInfo(planId))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updatePlanInfo(planId):
            return fetchPlanDetail(planId)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .setPlanInfo(plan):
            newState.plan = plan
        case .notifyLoadingState(let isLoad):
            newState.isLoading = isLoad
        case let .notifyMessage(message):
            newState.message = message
        }
        
        return newState
    }
}

extension PlanDetailViewReactor {
    private func fetchPlanDetail(_ planId: Int) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let fetchPlan = fetchPlanDetailUsecase.fetchPlanDetail(planId: planId)
            .asObservable()
            .map { Mutation.setPlanInfo($0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  fetchPlan,
                                  loadingStop])
    }
}



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
        case loadPlanInfo(_ planId: Int)
        case commentLoading(_ isLoading: Bool)
    }
    
    enum Mutation {
        case updatePlanInfo(_ Plan: Plan)
        case notifyPlanInfoLoading(_ isLoading: Bool)
        case notifyCommentLoading(_ isLoading: Bool)
        case notifyMessage(_ message: String)
    }
    
    struct State {
        @Pulse var plan: Plan?
        @Pulse var isLoading: Bool = false
        @Pulse var isCommentLoading: Bool = false
        @Pulse var message: String?
    }
    
    private let fetchPlanDetailUsecase: FetchPlanDetail
    
    var initialState: State = State()
    
    init(planId: Int,
         fetchPlanDetailUseCase: FetchPlanDetail) {
        self.fetchPlanDetailUsecase = fetchPlanDetailUseCase
        logLifeCycle()
        action.onNext(.loadPlanInfo(planId))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .loadPlanInfo(planId):
            return fetchPlanDetail(planId)
        case let .commentLoading(isLoad):
            return .just(.notifyCommentLoading(isLoad))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updatePlanInfo(plan):
            newState.plan = plan
        case .notifyPlanInfoLoading(let isLoad):
            newState.isLoading = isLoad
        case let .notifyMessage(message):
            newState.message = message
        case let .notifyCommentLoading(isLoad):
            newState.isCommentLoading = isLoad
        }
        
        return newState
    }
}

extension PlanDetailViewReactor {
    private func fetchPlanDetail(_ planId: Int) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyPlanInfoLoading(true))
        
        let fetchPlan = fetchPlanDetailUsecase.execute(planId: planId)
            .asObservable()
            .map { Mutation.updatePlanInfo($0) }
        
        let loadingStop = Observable.just(Mutation.notifyPlanInfoLoading(false))
        
        return Observable.concat([loadingStart,
                                  fetchPlan,
                                  loadingStop])
    }
}

extension PlanDetailViewReactor: LoadingStateDelegate  {
    func notifyLoading(_ isLoading: Bool) {
        action.onNext(.commentLoading(isLoading))
    }
}


//
//  FuturePlanListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation
import ReactorKit

final class FutruePlanListViewReactor: Reactor {
    
    enum Action {
        case requestPlanList
        case updateParticipants(id: Int, isJoining: Bool)
    }
    
    enum Mutation {
        case fetchPlanList(plans: [Plan])
        case notifyLoadingState(_ isLoading: Bool)
        case updatePlanParticipant(planId: Int)
    }
    
    struct State {
        @Pulse var plans: [Plan] = []
        @Pulse var isLoading: Bool = false
        @Pulse var completedJoin: Void?
    }
    
    var initialState: State = State()
    
    let fetchPlanUseCase: FetchMeetFuturePlan
    let requestJoinPlanUseCase: RequestJoinPlan
    let requestLeavePlanUseCase: RequestLeavePlan
    let meedId: Int
    
    init(fetchPlanUseCase: FetchMeetFuturePlan,
         requestJoinPlanUseCase: RequestJoinPlan,
         requsetLeavePlanUseCase: RequestLeavePlan,
         meetID: Int) {
        print(#function, #line, "LifeCycle Test FutruePlanListViewReactor Created" )

        self.fetchPlanUseCase = fetchPlanUseCase
        self.requestJoinPlanUseCase = requestJoinPlanUseCase
        self.requestLeavePlanUseCase = requsetLeavePlanUseCase
        self.meedId = meetID
        action.onNext(.requestPlanList)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test FutruePlanListViewReactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestPlanList:
            return fetchPlanList()
        case let .updateParticipants(id, isJoining):
            return requestParticipationPlan(planId: id, isJoining: isJoining)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchPlanList(plans):
            newState.plans = plans
        case let .notifyLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .updatePlanParticipant(planId):
            self.updatePlanParticipant(state: &newState, planId: planId)
        }
        
        return newState
    }
    
    private func updatePlanParticipant(state: inout State,
                                       planId: Int) {
        guard let index = state.plans.firstIndex(where: { $0.id == planId }) else { return }
        state.plans[index].isParticipating.toggle()
    }
}

extension FutruePlanListViewReactor {
    private func fetchPlanList() -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let fetchPlanList = fetchPlanUseCase.fetchPlan(meetId: meedId)
            .map({ Mutation.fetchPlanList(plans: $0) })
            .asObservable()
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  fetchPlanList,
                                  loadingStop])
    }
    
    private func requestParticipationPlan(planId: Int, isJoining: Bool) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let requestParticipation = Observable.just(isJoining)
            .flatMap { [weak self] isJoining in
                guard let self = self else { throw AppError.unknownError }
                
                if isJoining {
                    return self.requestJoinPlanUseCase.requestJoinPlan(planId: planId)
                } else {
                    return self.requestLeavePlanUseCase.requstLeavePlan(planId: planId)
                }
            }
            .map { Mutation.updatePlanParticipant(planId: planId) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  requestParticipation,
                                  loadingStop])
    }                                       
}


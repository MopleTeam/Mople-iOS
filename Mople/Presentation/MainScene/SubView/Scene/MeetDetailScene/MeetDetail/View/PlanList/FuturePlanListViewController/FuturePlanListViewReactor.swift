//
//  FuturePlanListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation
import ReactorKit

final class FuturePlanListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case selectedPlan(index: Int)
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
    
    private let fetchPlanUseCase: FetchMeetFuturePlan
    private let participationPlanUseCase: RequestParticipationPlan
    private weak var coordinator: MeetDetailCoordination?
    private let meedId: Int
    
    init(fetchPlanUseCase: FetchMeetFuturePlan,
         participationPlanUseCase: RequestParticipationPlan,
         coordinator: MeetDetailCoordination,
         meetID: Int) {
        self.fetchPlanUseCase = fetchPlanUseCase
        self.participationPlanUseCase = participationPlanUseCase
        self.coordinator = coordinator
        self.meedId = meetID
        action.onNext(.requestPlanList)
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestPlanList:
            fetchPlanList()
        case let .updateParticipants(id, isJoining):
            requestParticipationPlan(planId: id, isJoining: isJoining)
        case let .selectedPlan(index):
            presentPlanDetailView(index: index)
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

extension FuturePlanListViewReactor {
    private func fetchPlanList() -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let fetchPlanList = fetchPlanUseCase.fetchPlanList(meetId: meedId)
            .map({ Mutation.fetchPlanList(plans: $0) })
            .asObservable()
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  fetchPlanList,
                                  loadingStop])
    }
    
    private func requestParticipationPlan(planId: Int,
                                          isJoining: Bool) -> Observable<Mutation> {
        
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let requestParticipation = Observable.just(isJoining)
            .flatMap { [weak self] isJoining in
                guard let self = self else { throw AppError.unknownError }
                return self.participationPlanUseCase.requestParticipationPlan(planId: planId,
                                                                              isJoining: isJoining)
            }
            .map { Mutation.updatePlanParticipant(planId: planId) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  requestParticipation,
                                  loadingStop])
    }
    
    private func presentPlanDetailView(index: Int) -> Observable<Mutation> {
        guard let selectedPlan = currentState.plans[safe: index] else { return .empty() }
        self.coordinator?.pushPlanDetailView(plan: selectedPlan)
        return .empty()
    }
}


//
//  FuturePlanListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation
import ReactorKit

final class MeetPlanListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case selectedPlan(index: Int)
        case requestPlanList
        case updateParticipants(id: Int, isJoining: Bool)
        case updatePlan(_ planPayload: PlanPayload)
    }
    
    enum Mutation {
        case fetchPlanList([Plan])
        case notifyLoadingState(_ isLoading: Bool)
        case updatePlanParticipant(planId: Int)
    }
    
    struct State {
        @Pulse var plans: [Plan] = []
        @Pulse var isLoading: Bool = false
        @Pulse var completedJoin: Void?
    }
    
    var initialState: State = State()
    
    private let fetchPlanUseCase: FetchMeetPlanList
    private let participationPlanUseCase: RequestParticipationPlan
    private weak var coordinator: MeetDetailCoordination?
    private let meedId: Int
    
    init(fetchPlanUseCase: FetchMeetPlanList,
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
            return fetchPlanList()
        case let .updateParticipants(id, isJoining):
            return requestParticipationPlan(planId: id, isJoining: isJoining)
        case let .selectedPlan(index):
            return presentPlanDetailView(index: index)
        case let .updatePlan(payload):
            return handlePlanPayload(payload)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchPlanList(plans):
            newState.plans = plans.sorted(by: <)
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

extension MeetPlanListViewReactor {
    private func fetchPlanList() -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let fetchPlanList = fetchPlanUseCase.execute(meetId: meedId)
            .map({ Mutation.fetchPlanList($0) })
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
                return self.participationPlanUseCase.execute(planId: planId,
                                                                              isJoining: isJoining)
            }
            .map { Mutation.updatePlanParticipant(planId: planId) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  requestParticipation,
                                  loadingStop])
    }
    
    private func presentPlanDetailView(index: Int) -> Observable<Mutation> {
        guard let selectedPlan = currentState.plans[safe: index],
              let planId = selectedPlan.id else { return .empty() }
        self.coordinator?.pushPlanDetailView(postId: planId, type: .plan)
        return .empty()
    }
}

// MARK: - 일정 생성 알림 수신
extension MeetPlanListViewReactor {
    private func handlePlanPayload(_ payload: PlanPayload) -> Observable<Mutation> {
        var planList = currentState.plans
        
        switch payload {
        case let .created(plan):
            self.addPlan(&planList, plan: plan)
        case let .updated(plan):
            self.updatePlan(&planList, plan: plan)
        case let .deleted(plan):
            self.deletePlan(&planList, plan: plan)
        }
        return .just(.fetchPlanList(planList))
    }
    
    private func addPlan(_ planList: inout [Plan], plan: Plan) {
        planList.append(plan)
        planList.sort(by: <)
    }
    
    private func updatePlan(_ planList: inout [Plan], plan: Plan) {
        guard let updatedIndex = planList.firstIndex(where: {
            $0.id == plan.id
        }) else { return }
        
        planList[updatedIndex] = plan
        planList.sort(by: <)
    }
    
    private func deletePlan(_ planList: inout [Plan], plan: Plan) {
        planList.removeAll { $0.id == plan.id }
    }
}

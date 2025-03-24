//
//  FuturePlanListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation
import ReactorKit

protocol MeetPlanListCommands: AnyObject {
    func reset()
}

final class MeetPlanListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case selectedPlan(index: Int)
        case requestPlanList
        case updateParticipants(id: Int, isJoining: Bool)
        case updatePlan(_ planPayload: PlanPayload)
    }
    
    enum Mutation {
        case fetchPlanList([Plan])
        case closePlan(id: Int)
    }
    
    struct State {
        @Pulse var plans: [Plan] = []
        @Pulse var completedJoin: Void?
        @Pulse var closingPlanIndex: Int?
    }
    
    var initialState: State = State()
    
    private let fetchPlanUseCase: FetchMeetPlanList
    private let participationPlanUseCase: ParticipationPlan
    private weak var delegate: MeetDetailDelegate?
    private let meedId: Int
    
    init(fetchPlanUseCase: FetchMeetPlanList,
         participationPlanUseCase: ParticipationPlan,
         delegate: MeetDetailDelegate,
         meetID: Int) {
        self.fetchPlanUseCase = fetchPlanUseCase
        self.participationPlanUseCase = participationPlanUseCase
        self.delegate = delegate
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
        case let .closePlan(id):
            closePlan(state: &newState, id: id)
        }
        
        return newState
    }
        
    private func closePlan(state: inout State, id: Int) {
        guard let closePlanIndex = state.plans.firstIndex(where: { $0.id == id }) else { return }
        state.closingPlanIndex = closePlanIndex
    }
}

extension MeetPlanListViewReactor {
    private func fetchPlanList() -> Observable<Mutation> {
        
        let fetchPlanList = fetchPlanUseCase.execute(meetId: meedId)
            .map({ Mutation.fetchPlanList($0) })
            .asObservable()

        return requestWithLoading(task: fetchPlanList)
    }
    
    private func requestParticipationPlan(planId: Int,
                                          isJoining: Bool) -> Observable<Mutation> {
        
        guard let planIndex = currentState.plans.firstIndex(where: { $0.id == planId }) else {
            return .empty()
        }
        
        if checkPlanTime(planIndex: planIndex) {
            let requestParticipation = participationPlanUseCase.execute(planId: planId,
                                                                        isJoining: isJoining)
                .asObservable()
                .flatMap { [weak self] _ -> Observable<Mutation> in
                    guard let self else { return .empty() }
                    return handleParticipants(planIndex: planIndex)
                }
            
            return requestWithLoading(task: requestParticipation)
        } else {
            return .just(.closePlan(id: planId))
        }
    }
    
    private func checkPlanTime(planIndex: Int) -> Bool {
        guard let planDate = currentState.plans[planIndex].date else { return false }
        return planDate > Date()
    }
    
    private func handleParticipants(planIndex: Int) -> Observable<Mutation> {
        var currentPlans = currentState.plans
        let changePlan = currentPlans[planIndex].updateParticipants()
        postParticipants(with: changePlan)
        return .just(.fetchPlanList(currentPlans))
    }
    
    private func postParticipants(with plan: Plan) {
        if plan.isParticipating {
            EventService.shared.postItem(.created(plan), from: self)
        } else {
            guard let id = plan.id else { return }
            EventService.shared.postItem(PlanPayload.deleted(id: id), from: self)
        }
    }
}

// MARK: - 일정 선택
extension MeetPlanListViewReactor {
    
    private func presentPlanDetailView(index: Int) -> Observable<Mutation> {
        guard let selectedPlan = currentState.plans[safe: index],
              let planId = selectedPlan.id else { return .empty() }
        
        handlePlanDate(id: planId,
                       with: selectedPlan)
        
        return .empty()
    }
    
    private func handlePlanDate(id: Int,
                               with plan: Plan) {
        guard let date = plan.date else { return }
        
        if DateManager.isPastDay(on: date) == false {
            delegate?.selectedPlan(id: id,
                                   type: .plan)
        } else {
            parent?.catchError(PlanDetailError.expiredPlan(date), index: 1)
        }
    }
}

extension MeetPlanListViewReactor: MeetPlanListCommands {
    func reset() {
        action.onNext(.requestPlanList)
    }
}

// MARK: - 일정 알림 수신
extension MeetPlanListViewReactor {
    private func handlePlanPayload(_ payload: PlanPayload) -> Observable<Mutation> {
        var planList = currentState.plans
        
        switch payload {
        case let .created(plan):
            self.addPlan(&planList, plan: plan)
        case let .updated(plan):
            self.updatePlan(&planList, plan: plan)
        case let .deleted(id):
            self.deletePlan(&planList, planId: id)
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
    
    private func deletePlan(_ planList: inout [Plan], planId: Int) {
        planList.removeAll { $0.id == planId }
    }
}

extension MeetPlanListViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
    var index: Int { 0 }
}

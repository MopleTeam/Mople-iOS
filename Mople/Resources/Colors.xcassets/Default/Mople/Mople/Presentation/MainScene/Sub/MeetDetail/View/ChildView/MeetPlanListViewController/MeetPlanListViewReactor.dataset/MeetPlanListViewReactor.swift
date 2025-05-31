//
//  FuturePlanListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation
import ReactorKit

protocol MeetPlanListCommands: AnyObject {
    func fetchPlan()
}

final class MeetPlanListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case selectedPlan(index: Int)
        case requestPlanList
        case requsetParticipation(id: Int, isJoining: Bool)
        case switchParticipation(id: Int)
        case updatePlan(_ planPayload: PlanPayload)
        case refresh
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
    
    // MARK: - Variables
    var initialState: State = State()
    private let meetId: Int
    private var selectedPlanId: Int?
    
    // MARK: - UseCase
    private let fetchPlanUseCase: FetchMeetPlanList
    private let participationPlanUseCase: ParticipationPlan
    
    // MARK: - Delegate
    private weak var delegate: MeetDetailDelegate?
    
    // MARK: - LifeCycle
    init(fetchPlanUseCase: FetchMeetPlanList,
         participationPlanUseCase: ParticipationPlan,
         delegate: MeetDetailDelegate,
         meetId: Int) {
        self.fetchPlanUseCase = fetchPlanUseCase
        self.participationPlanUseCase = participationPlanUseCase
        self.delegate = delegate
        self.meetId = meetId
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestPlanList:
            return fetchPlanList()
        case let .requsetParticipation(id, isJoining):
            return handleParticipation(planId: id, isJoining: isJoining)
        case let .selectedPlan(index):
            return presentPlanDetailView(index: index)
        case let .updatePlan(payload):
            return handlePlanPayload(payload)
        case let .switchParticipation(id):
            return switchParticipation(planId: id)
        case .refresh:
            return refreshPlanList()
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
        
    private func closePlan(state: inout State,
                           id: Int) {
        guard let closePlanIndex = state.plans.firstIndex(where: { $0.id == id }) else { return }
        state.closingPlanIndex = closePlanIndex
    }
}

// MARK: - Data Request
extension MeetPlanListViewReactor {
    
    // MARK: - 일정 리스트 받아오기

    /// 일정 리스트  불러오기
    private func fetchPlanList() -> Observable<Mutation> {
        let fetchPlanList = fetchPlanUseCase.execute(meetId: meetId)
            .catchAndReturn([])
            .map({ Mutation.fetchPlanList($0) })
        return requestWithLoading(task: fetchPlanList)
    }
    
    /// 일정 리스트 리프레쉬
    private func refreshPlanList() -> Observable<Mutation> {
        delegate?.refresh()
        return .empty()
    }

    // MARK: - 참여 핸들링
    // 일정이 과거인 경우 : reload post
    // 일정이 사라진 경우 : delete post
    // 일정 시간이 마감된 경우 : UI 업데이트
    private func handleParticipation(planId: Int,
                                     isJoining: Bool) -> Observable<Mutation> {
        
        guard let planIndex = currentState.plans.firstIndex(where: { $0.id == planId }),
              let planDate = currentState.plans[safe: planIndex]?.date else { return .empty() }
        switch planDate {
        case _ where DateManager.isPastDay(on: planDate):
            parent?.catchError(DateTransitionError.midnightReset, index: 1)
            return .empty()
        case _ where planDate < Date():
            return .just(.closePlan(id: planId))
        default:
            return requestParticipation(id: planId,
                                        planIndex: planIndex,
                                        isJoining: isJoining)
        }
    }
    
    private func requestParticipation(id: Int,
                                      planIndex: Int,
                                      isJoining: Bool) -> Observable<Mutation> {
        let requestParticipation = participationPlanUseCase
            .execute(planId: id,
                     isJoining: isJoining)
            .catch({ [weak self] in
                let err = self?.resolveParticipationError(err: $0,
                                                          planId: id)
                return .error(err ?? $0)
                
            })
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self else { return .empty() }
                return updateParticipation(planIndex: planIndex)
            }
        return requestWithLoading(task: requestParticipation)
    }
    
    private func updateParticipation(planIndex: Int) -> Observable<Mutation> {
        var currentPlans = currentState.plans
        let changePlan = currentPlans[planIndex].updateParticipants()
        postParticipants(with: changePlan)
        return .just(.fetchPlanList(currentPlans))
    }
    
    private func postParticipants(with plan: Plan) {
        guard let planId = plan.id else { return }
        let payload: NotificationManager.ParticipationPayload
        = plan.isParticipation
        ? .participating(plan)
        : .notParticipation(id: planId)
        NotificationManager.shared.postParticipating(payload,
                                                     from: self)
    }
    
    private func resolveParticipationError(err: Error,
                                           planId: Int) -> ResponseError? {
        guard let dataError = err as? DataRequestError else { return nil }
        return DataRequestError.resolveNoResponseError(err: dataError,
                                                       responseType: .plan(id: planId))
    }
}

// MARK: - Selected Plan
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
            selectedPlanId = id
            delegate?.selectedPlan(id: id,
                                   type: .plan)
        } else {
            parent?.catchError(DateTransitionError.midnightReset, index: 1)
        }
    }
}

// MARK: - Notify
extension MeetPlanListViewReactor {
    
    // MARK: - Plan Payload
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
    
    // MARK: - Plan Particiaption
    private func switchParticipation(planId: Int) -> Observable<Mutation> {
        var currentPlans = currentState.plans
        guard let switchIndex = currentPlans.firstIndex(where: { $0.id == planId }) else {
            return .empty()
        }
        currentPlans[switchIndex].updateParticipants()
        return .just(.fetchPlanList(currentPlans))
    }
}

// MARK: - Commands
extension MeetPlanListViewReactor: MeetPlanListCommands {
    func fetchPlan() {
        action.onNext(.requestPlanList)
    }
}

// MARK: - Loading & Error
extension MeetPlanListViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
    var index: Int { 0 }
}

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
    
    // MARK: - Variables
    var initialState: State = State()
    private let meetId: Int
    
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
        case let .updateParticipants(id, isJoining):
            return handleParticipation(planId: id, isJoining: isJoining)
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
        
    private func closePlan(state: inout State,
                           id: Int) {
        guard let closePlanIndex = state.plans.firstIndex(where: { $0.id == id }) else { return }
        state.closingPlanIndex = closePlanIndex
    }
}

// MARK: - Data Request
extension MeetPlanListViewReactor {
    
    // MARK: - 일정 리스트 받아오기
    private func fetchPlanList() -> Observable<Mutation> {
        
        let fetchPlanList = fetchPlanUseCase.execute(meetId: meetId)
            .catchAndReturn([])
            .map({ Mutation.fetchPlanList($0) })
            .asObservable()

        return requestWithLoading(task: fetchPlanList)
    }

    // MARK: - 참여 핸들링
    // 일정 시간이 마감된 경우 : UI 업데이트
    // 일정이 과거인 경우 : reload post
    // 일정이 사라진 경우 : delete post
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
        let requestParticipation = participationPlanUseCase.execute(planId: id,
                                                                    isJoining: isJoining)
            .asObservable()
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
        if plan.isParticipating {
            EventService.shared.postParticipating(.participating(plan),
                                                  from: self)
        } else {
            guard let id = plan.id else { return }
            EventService.shared.postParticipating(.notParticipation(id: id),
                                                  from: self)
        }
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
            delegate?.selectedPlan(id: id,
                                   type: .plan)
        } else {
            parent?.catchError(DateTransitionError.midnightReset, index: 1)
        }
    }
}

// MARK: - Notify
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

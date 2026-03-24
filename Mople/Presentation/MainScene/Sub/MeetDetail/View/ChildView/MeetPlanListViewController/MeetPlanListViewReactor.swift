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
        case fetchPlan
        case fetchNextPlan
        case selectedPlan(index: Int)
        case requsetParticipation(id: Int, isJoin: Bool)
        case switchParticipation(id: Int)
        case updatePlan(_ planPayload: PlanPayload)
        case refresh
    }
    
    enum Mutation {
        case fetchPlanList([Plan])
        case updateTotalCount(Int)
        case closePlan(id: Int)
    }
    
    struct State {
        @Pulse var plans: [Plan] = []
        @Pulse var totolPlanCount: Int = 0
        @Pulse var closingPlanIndex: Int?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var isLoading = false
    private let meetId: Int
    private(set) var page: PageInfo?
    
    // MARK: - UseCase
    private let fetchPlanUseCase: FetchPlanPage
    private let participationPlanUseCase: ParticipationPlan
    
    // MARK: - Delegate
    private weak var delegate: MeetDetailDelegate?
    
    // MARK: - LifeCycle
    init(fetchPlanUseCase: FetchPlanPage,
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
    
    private func initalAction() {
        action.onNext(.fetchPlan)
    }

    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        guard !isLoading else { return .empty() }
        switch action {
        case .fetchPlan:
            return fetchPlan(isRefresh: true)
        case .fetchNextPlan:
            return fetchNextPage()
        case let .requsetParticipation(id, isJoin):
            return handleParticipation(planId: id, isJoin: isJoin)
        case let .selectedPlan(index):
            return presentPlanDetailView(index: index)
        case let .updatePlan(payload):
            return handlePlanPayload(payload)
        case let .switchParticipation(id):
            return switchParticipation(planId: id)
        case .refresh:
            return refresh()
        }
    }
    
    private func shouldAction(_ action: Action) -> Bool {
        switch action {
        case .fetchPlan, .fetchNextPlan, .requsetParticipation, .refresh:
            return !isLoading
        default:
            return true
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchPlanList(plans):
            newState.plans = plans
        case let .updateTotalCount(count):
            newState.totolPlanCount = count
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
    
    /// 일정 리스트 불러오기
    private func fetchPlan(cursor: String? = nil,
                           isRefresh: Bool = false) -> Observable<Mutation> {
        var totalCount: Int = 0
        let fetchPlan = fetchPlanUseCase.execute(meetId: meetId, cursor: cursor)
            .map({ result in
                self.page = result.info
                totalCount = result.totalCount
                return self.updatePlanList(isRefresh: isRefresh, plans: result.content)
            })
            .flatMap {
                return Observable.of($0, .updateTotalCount(totalCount))
            }
        return requestWithLoading(task: fetchPlan,
                                  defferredLoadingDelay: .milliseconds(300))
    }
    
    private func updatePlanList(isRefresh: Bool, plans: [Plan]) -> Mutation {
        var newPlans = currentState.plans
        if isRefresh {
            newPlans = plans
        } else {
            newPlans.append(contentsOf: plans)
            newPlans.uniqueSorted()
        }
        return .fetchPlanList(newPlans)
    }
    
    /// 일정 다음 페이지 불러오기
    private func fetchNextPage() -> Observable<Mutation> {
        guard let cursor = page?.nextCursor else { return .empty() }
        return fetchPlan(cursor: cursor)
    }
    
    private func refresh() -> Observable<Mutation> {
        delegate?.refresh()
        return .empty()
    }
    
    // MARK: - 참여 핸들링
    // 일정이 과거인 경우 : reload post
    // 일정이 사라진 경우 : delete post
    // 일정 시간이 마감된 경우 : UI 업데이트
    private func handleParticipation(planId: Int,
                                     isJoin: Bool) -> Observable<Mutation> {
        
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
                                        isJoin: isJoin)
        }
    }
    
    private func requestParticipation(id: Int,
                                      planIndex: Int,
                                      isJoin: Bool) -> Observable<Mutation> {
        let participation = participationPlanUseCase
            .execute(planId: id,
                     isJoin: isJoin)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self else { return .empty() }
                return updateParticipation(planIndex: planIndex)
            }
            .catch({ [weak self] err -> Observable<Mutation> in
                guard let self else { return .empty() }
                let resolveErr = resolveParticipationError(err: err, planId: id)
                return .error(resolveErr ?? err)
            })
        return requestWithLoading(task: participation, defferredLoadingDelay: .milliseconds(300))
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
              let planId = selectedPlan.id,
              let planDate = selectedPlan.date else { return .empty() }
        
        if DateManager.isPastDay(on: planDate) == false {
            let isVaildPlan = planDate > Date()
            delegate?.selectedPlan(id: planId, type: .plan)
        } else {
            delegate?.catchError(DateTransitionError.midnightReset, index: 1)
        }
        return .empty()
    }
}

// MARK: - Notify
extension MeetPlanListViewReactor {
    
    // MARK: - Plan Payload
    private func handlePlanPayload(_ payload: PlanPayload) -> Observable<Mutation> {
        var planList = currentState.plans
        var totalCount = currentState.totolPlanCount
        
        switch payload {
        case let .created(plan):
            self.addPlan(&planList, plan: plan)
            totalCount += 1
        case let .updated(plan):
            self.updatePlan(&planList, plan: plan)
        case let .deleted(id):
            self.deletePlan(&planList, planId: id)
            totalCount -= 1
        }
        
        return .of(.fetchPlanList(planList), .updateTotalCount(max(totalCount, 0)))
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
        action.onNext(.fetchPlan)
    }
}

// MARK: - Loading & Error
extension MeetPlanListViewReactor: ChildLoadingReactor {
    func updateLoadingState(isLoad: Bool) {
        isLoading = isLoad
    }
    var parent: ChildLoadingDelegate? { delegate }
    var index: Int { 0 }
}

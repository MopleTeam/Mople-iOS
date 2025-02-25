//
//  ScheduleViewModel.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import ReactorKit

enum HomeError: Error {
    case emptyMeet
}

final class HomeViewReactor: Reactor, LifeCycleLoggable {

    enum Action {
        case checkNotificationPermission
        case createGroup
        case createPlan
        case presentCalendaer
        case requestRecentPlan
        case updatePlan(_ planPayload: PlanPayload)
        case updateMeet(_ meetPayload: MeetPayload)
    }
    
    enum Mutation {
        case updatePlanList(_ updatedPlanList: [Plan])
        case updateMeetList(_ updatedMeetList: [MeetSummary])
        case responseRecentPlan(schedules: RecentPlan)
        case notifyLoadingState(_ isLoading: Bool)
        case handleHomeError(error: HomeError?)
    }
    
    struct State {
        @Pulse var plans: [Plan] = []
        @Pulse var meetList: [MeetSummary] = []
        @Pulse var error: HomeError?
        @Pulse var isLoading: Bool = false
    }
    
    private let fetchRecentScheduleUseCase: FetchRecentPlan
    private let notificationService: NotificationService
    private weak var coordinator: HomeFlowCoordinator?
    
    var initialState: State = State()
    
    init(fetchRecentScheduleUseCase: FetchRecentPlan,
         notificationService: NotificationService,
         coordinator: HomeFlowCoordinator) {
        self.fetchRecentScheduleUseCase = fetchRecentScheduleUseCase
        self.notificationService = notificationService
        self.coordinator = coordinator
        logLifeCycle()
        action.onNext(.requestRecentPlan)
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestRecentPlan:
            fetchRecentSchedules()
        case .createGroup:
            presentMeetCreateView()
        case .createPlan:
            presentPlanCreateView()
        case .presentCalendaer:
            presentNextEvent()
        case .checkNotificationPermission:
            requestNotificationPermission()
        case let .updatePlan(payload):
            handlePlanPayload(payload)
        case let .updateMeet(payload):
            handleMeetPayload(payload)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .responseRecentPlan(let homeModel):
            let recentSchedules = homeModel.plans.sorted(by: <)
            newState.meetList = homeModel.meets
            newState.plans = recentSchedules
        case let .handleHomeError(err):
            newState.error = err
        case let .notifyLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .updatePlanList(planList):
            newState.plans = planList
        case let .updateMeetList(meetList):
            newState.meetList = meetList
        }
        return newState
    }
    
    func handleError(state: State, err: Error) -> State {
        let newState = state
        
        // 에러 처리
        
        return newState
    }
}
    

extension HomeViewReactor {
    private func fetchRecentSchedules() -> Observable<Mutation> {
        
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let fetchSchedules = Observable.just(())//
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap({ [weak self] _ -> Single<RecentPlan> in
                guard let self else { return .never() }
                return fetchRecentScheduleUseCase.execute()
            })
            .asObservable()
            .map { Mutation.responseRecentPlan(schedules: $0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  fetchSchedules,
                                  loadingStop])
    }
}

// MARK: - Flow
extension HomeViewReactor {
    #warning("정확한 날짜로 수정하기")
    private func presentNextEvent() -> Observable<Mutation> {
        guard !currentState.plans.isEmpty,
              let lastDate = currentState.plans.last?.date else { return .empty() }
        let startOfDay = DateManager.startOfDay(lastDate)
        coordinator?.pushCalendarView(lastRecentDate: startOfDay)
        return .empty()
    }
    
    private func presentMeetCreateView() -> Observable<Mutation> {
        coordinator?.presentMeetCreateView()
        return .empty()
    }
    
    private func presentPlanCreateView() -> Observable<Mutation> {
        let meetList = currentState.meetList
        guard meetList.isEmpty == false else { return .just(.handleHomeError(error: .emptyMeet)) }
        coordinator?.presentPlanCreateView(meetList: meetList)
        return .empty()
    }
}

// MARK: - Premission
extension HomeViewReactor {
    private func requestNotificationPermission() -> Observable<Mutation> {
        return Observable<Mutation>.create { observer in
            self.notificationService.requestPremission {
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - 일정 생성 알림 수신
extension HomeViewReactor {
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
        return .just(.updatePlanList(planList))
    }
    
    private func addPlan(_ planList: inout [Plan], plan: Plan) {
        planList.append(plan)
        planList.sort(by: <)
        
        if planList.count > 5 {
            planList.removeLast()
        }
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

// MARK: - 모임 생성 알림 수신
extension HomeViewReactor {
    private func handleMeetPayload(_ payload: MeetPayload) -> Observable<Mutation> {
        var meetList = currentState.meetList
        var planList = currentState.plans
        
        appleMeetChanged(payload: payload,
                         meetList: &meetList,
                         planList: &planList)
        
        switch payload {
        case .created:
            return .just(.updateMeetList(meetList))
        case .updated, .deleted:
            let planUpdated = Mutation.updatePlanList(planList)
            let meetUpdated = Mutation.updateMeetList(meetList)
            return .of(planUpdated, meetUpdated)
        }
    }
    
    private func appleMeetChanged(payload: MeetPayload,
                                  meetList: inout [MeetSummary],
                                  planList: inout [Plan]) {
        switch payload {
        case let .created(meet):
            addMeet(&meetList,
                    meet: meet)
        case let .updated(meet):
            editMeet(&meetList,
                     &planList,
                     editMeet: meet)
        case let .deleted(id):
            deleteMeet(&meetList,
                       &planList,
                       meetId: id)
        }
    }
    
    private func addMeet(_ meetList: inout [MeetSummary], meet: Meet) {
        guard let meetSummary = meet.meetSummary else { return }
        meetList.insert(meetSummary, at: 0)
    }
    
    private func editMeet(_ meetList: inout [MeetSummary],
                          _ planList: inout [Plan],
                          editMeet: Meet) {
        planList = changePlanMeetInfo(planList: planList,
                                      editMeet: editMeet)
        
        meetList = replaceMeet(meetList: meetList,
                               editMeet: editMeet)
    }
    
    private func changePlanMeetInfo(planList: [Plan],
                                    editMeet: Meet) -> [Plan] {
        return planList.map({
            var plan = $0
            guard plan.meet?.id == editMeet.meetSummary?.id else { return $0 }
            plan.meet?.name = editMeet.meetSummary?.name
            plan.meet?.imagePath = editMeet.meetSummary?.imagePath
            return plan
        })
    }
    
    private func replaceMeet(meetList: [MeetSummary],
                             editMeet: Meet) -> [MeetSummary] {
        meetList.map({
            guard $0.id == editMeet.meetSummary?.id,
                  let meetSummary = editMeet.meetSummary else { return $0 }
            return meetSummary
        })
    }
    
    private func deleteMeet(_ meetList: inout [MeetSummary],
                            _ planList: inout [Plan],
                            meetId: Int) {
        planList.removeAll { $0.meet?.id == meetId }
        meetList.removeAll { $0.id == meetId }
    }
}

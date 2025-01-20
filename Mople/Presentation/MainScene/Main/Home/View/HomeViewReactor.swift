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
    private let coordinator: HomeFlowCoordinator
    
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
        
        let fetchSchedules = fetchRecentScheduleUseCase.fetchRecentPlan()
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
        coordinator.pushCalendarView(lastRecentDate: startOfDay)
        return .empty()
    }
    
    private func presentMeetCreateView() -> Observable<Mutation> {
        coordinator.presentMeetCreateView()
        return .empty()
    }
    
    private func presentPlanCreateView() -> Observable<Mutation> {
        let meetList = currentState.meetList
        guard meetList.isEmpty == false else { return .just(.handleHomeError(error: .emptyMeet)) }
        coordinator.presentPlanCreateView(meetList: meetList)
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
        print(#function, #line, "payload : \(payload)" )
        var planList = currentState.plans
        
        switch payload {
        case let .created(plan):
            self.addMeet(&planList, plan: plan)
        case let .updated(plan):
            self.updatedMeet(&planList, plan: plan)
        case let .deleted(plan):
            self.deleteMeet(&planList, plan: plan)
        }
        return .just(.updatePlanList(planList))
    }
    
    private func addMeet(_ planList: inout [Plan], plan: Plan) {
        planList.append(plan)
        planList.sort(by: <)
        
        if planList.count > 5 {
            planList.removeLast()
        }
    }
    
    private func updatedMeet(_ planList: inout [Plan], plan: Plan) {
        guard let updatedIndex = planList.firstIndex(where: {
            $0.id == plan.id
        }) else { return }
        
        planList[updatedIndex] = plan
    }
    
    private func deleteMeet(_ planList: inout [Plan], plan: Plan) {
        planList.removeAll { $0.id == plan.id }
    }
}

// MARK: - 모임 생성 알림 수신
extension HomeViewReactor {
    private func handleMeetPayload(_ payload: MeetPayload) -> Observable<Mutation> {
        var meetList = currentState.meetList
        
        switch payload {
        case let .created(meet):
            self.addMeet(&meetList, meet: meet)
        case let .deleted(meet):
            self.deleteMeet(&meetList, meet: meet)
        default:
            break
        }
        return .just(.updateMeetList(meetList))
    }
    
    private func addMeet(_ meetList: inout [MeetSummary], meet: Meet) {
        guard let meetSummary = meet.meetSummary else { return }
        meetList.insert(meetSummary, at: 0)
    }
    
    private func deleteMeet(_ meetList: inout [MeetSummary], meet: Meet) {
        meetList.removeAll { $0.id == meet.meetSummary?.id }
    }
}

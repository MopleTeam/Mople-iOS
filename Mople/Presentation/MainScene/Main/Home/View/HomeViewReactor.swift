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
        enum Flow {
            case planDetail(index: Int)
            case createGroup
            case createPlan
            case calendar
        }
        
        case flow(Flow)
        case checkNotificationPermission
        case fetchHomeData
        case updatePlan(_ planPayload: PlanPayload)
        case updateMeet(_ meetPayload: MeetPayload)
        case reloadDay(Date)
    }
    
    enum Mutation {
        case updatePlanList(_ updatedPlanList: [Plan])
        case updateMeetList(_ updatedMeetList: [MeetSummary])
        case updateHomeData(HomeData)
        case notifyLoadingState(_ isLoading: Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var plans: [Plan] = []
        @Pulse var meetList: [MeetSummary] = []
        @Pulse var error: Error?
        @Pulse var isLoading: Bool = false
    }
    
    private let fetchRecentScheduleUseCase: FetchHomeData
    private let notificationService: NotificationService
    private weak var coordinator: HomeFlowCoordinator?
    
    var initialState: State = State()
    
    init(fetchRecentScheduleUseCase: FetchHomeData,
         notificationService: NotificationService,
         coordinator: HomeFlowCoordinator) {
        self.fetchRecentScheduleUseCase = fetchRecentScheduleUseCase
        self.notificationService = notificationService
        self.coordinator = coordinator
        logLifeCycle()
        action.onNext(.fetchHomeData)
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchHomeData:
            return fetchHomeData()
        case let .flow(action):
            return handleFlowAction(with: action)

        case .checkNotificationPermission:
            return requestNotificationPermission()
        case let .updatePlan(payload):
            return handlePlanPayload(payload)
        case let .updateMeet(payload):
            return handleMeetPayload(payload)
        case let .reloadDay(day):
            return reloadDay(on: day)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .updateHomeData(let homeData):
            newState.meetList = homeData.meets
            newState.plans = homeData.plans.sorted(by: <)
        case let .notifyLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .updatePlanList(planList):
            newState.plans = planList
        case let .updateMeetList(meetList):
            newState.meetList = meetList
        case let .catchError(err):
            handleError(state: &newState, err: err)
        }
        return newState
    }
    
    func handleError(state: inout State, err: Error) {
        switch err {
        default:
            state.error = err
        }
    }
}
    

extension HomeViewReactor {
    private func fetchHomeData() -> Observable<Mutation> {
        
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let fetchSchedules = fetchRecentScheduleUseCase.execute()
            .asObservable()
            .catchAndReturn(.init(plans: [], meets: []))
            .map { Mutation.updateHomeData($0) }

        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  fetchSchedules,
                                  loadingStop])
    }
}

// MARK: - Flow
extension HomeViewReactor {
    
    private func handleFlowAction(with action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case .calendar:
            return presentNextEvent()
        case .createGroup:
            return presentMeetCreateView()
        case .createPlan:
            return presentPlanCreateView()
        case let .planDetail(index):
            return presentPlanDetail(index: index)
        }
    }
    
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
        guard meetList.isEmpty == false else { return .just(.catchError(HomeError.emptyMeet)) }
        coordinator?.presentPlanCreateView(meetList: meetList)
        return .empty()
    }
    
    private func presentPlanDetail(index: Int) -> Observable<Mutation> {
        guard let plan = currentState.plans[safe: index],
              let id = plan.id,
              let date = plan.date else { return .empty() }
        
        if DateManager.isPastDay(on: date) == false {
            coordinator?.presentPlanDetailView(planId: id)
            return .empty()
        } else {
            return .just(.catchError(PlanDetailError.expiredPlan(date)))
        }
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
            return addPlan(&planList, plan: plan)
        case let .updated(plan):
            return updatePlan(&planList, plan: plan)
        case let .deleted(id):
            return deletePlan(planList, planId: id)
        }
    }
    
    private func addPlan(_ planList: inout [Plan], plan: Plan) -> Observable<Mutation> {
        planList.append(plan)
        planList.sort(by: <)
        
        if planList.count > 5 {
            planList.removeLast()
        }
        
        return .just(.updatePlanList(planList))
    }
    
    private func updatePlan(_ planList: inout [Plan], plan: Plan) -> Observable<Mutation> {
        guard let updatedIndex = planList.firstIndex(where: {
            $0.id == plan.id
        }) else { return .empty() }
        
        planList[updatedIndex] = plan
        planList.sort(by: <)
        
        return .just(.updatePlanList(planList))
    }
    
    private func deletePlan(_ planList: [Plan], planId: Int) -> Observable<Mutation> {
        guard planList.contains(where: { $0.id == planId }) else { return .empty() }
        action.onNext(.fetchHomeData)
        return .empty()
    }
}

// MARK: - 모임 생성 알림 수신
extension HomeViewReactor {
    private func handleMeetPayload(_ payload: MeetPayload) -> Observable<Mutation> {
        switch payload {
        case let .created(meet):
            return addMeet(meet: meet)
        case let .updated(meet):
            let planUpdated = updatePlanMeetInfo(editMeet: meet)
            let meetUpdated = updateMeetList(editMeet: meet)
            return .merge(planUpdated, meetUpdated)
        case let .deleted(id):
            return deleteMeet(meetId: id)
        }
    }
    
    private func addMeet(meet: Meet) -> Observable<Mutation> {
        guard let meetSummary = meet.meetSummary else { return .empty() }
        var currentMeetList = currentState.meetList
        currentMeetList.insert(meetSummary, at: 0)
        return .just(.updateMeetList(currentMeetList))
    }
    
    private func updatePlanMeetInfo(editMeet: Meet) -> Observable<Mutation> {
        let updatePlan = currentState.plans.map({
            var plan = $0
            guard plan.meet?.id == editMeet.meetSummary?.id else { return $0 }
            plan.meet?.name = editMeet.meetSummary?.name
            plan.meet?.imagePath = editMeet.meetSummary?.imagePath
            return plan
        })
        return .just(.updatePlanList(updatePlan))
    }
    
    private func updateMeetList(editMeet: Meet) -> Observable<Mutation> {
        let updateMeet = currentState.meetList.map {
            guard $0.id == editMeet.meetSummary?.id,
                  let meetSummary = editMeet.meetSummary else { return $0 }
            return meetSummary
        }
        return .just(.updateMeetList(updateMeet))
    }
    
    private func deleteMeet(meetId: Int) -> Observable<Mutation> {
        if currentState.plans.contains(where: { $0.meet?.id == meetId }) {
            action.onNext(.fetchHomeData)
        }
        
        return .empty()
    }
}

// MARK: - 새로고침
extension HomeViewReactor {
    private func reloadDay(on date: Date) -> Observable<Mutation> {
        if currentState.plans.contains(where: {
            guard let planDate = $0.date else { return false }
            return DateManager.isSameDay(planDate, date) || planDate < date
        }) {
            action.onNext(.fetchHomeData)
        }
                
        return .empty()
    }
}

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
    case midnight(DateTransitionError)
    case unknown(Error)
}

final class HomeViewReactor: Reactor, LifeCycleLoggable {

    enum Action {
        enum Flow {
            case planDetail(index: Int)
            case createGroup
            case createPlan
            case calendar
            case notify
        }
        
        case flow(Flow)
        case checkNotificationPermission
        case fetchHomeData
        case fetchNotifyStatus
        case updatePlan(_ planPayload: PlanPayload)
        case updateMeet(_ meetPayload: MeetPayload)
        case reloadDay
    }
    
    enum Mutation {
        case updatePlanList(_ updatedPlanList: [Plan])
        case updateMeetList(_ updatedMeetList: [MeetSummary])
        case updateHomeData(HomeData)
        case updateNotifyStatus(Bool)
        case updateLoadingState(Bool)
        case catchError(HomeError)
    }
    
    struct State {
        @Pulse var plans: [Plan] = []
        @Pulse var meetList: [MeetSummary] = []
        @Pulse var hasNotify: Bool = false
        @Pulse var isLoading: Bool = false
        @Pulse var error: HomeError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let isLogin: Bool
    
    // MARK: - UseCcase
    private let uploadFCMTokenUseCase: UploadFCMToken
    private let fetchRecentScheduleUseCase: FetchHomeData
    
    // MARK: - Notification
    private let notificationService: NotificationService
    
    // MARK: - Coordinator
    private weak var coordinator: HomeFlowCoordinator?
    
    // MARK: - LifeCycle
    init(isLogin: Bool,
         uploadFCMTokcnUseCase: UploadFCMToken,
         fetchRecentScheduleUseCase: FetchHomeData,
         notificationService: NotificationService,
         coordinator: HomeFlowCoordinator) {
        self.isLogin = isLogin
        self.uploadFCMTokenUseCase = uploadFCMTokcnUseCase
        self.fetchRecentScheduleUseCase = fetchRecentScheduleUseCase
        self.notificationService = notificationService
        self.coordinator = coordinator
        initialAction()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Initital Setup
    private func initialAction() {
        uploadFCMToken()
        action.onNext(.fetchHomeData)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchHomeData:
            return fetchHomeData()
        case .fetchNotifyStatus:
            return fetchNoticationStatus()
        case let .flow(action):
            return handleFlowAction(with: action)
        case .checkNotificationPermission:
            return requestNotificationPermission()
        case let .updatePlan(payload):
            return handlePlanPayload(payload)
        case let .updateMeet(payload):
            return handleMeetPayload(payload)
        case .reloadDay:
            return reloadDay()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateHomeData(homeData):
            newState.meetList = homeData.meets
            newState.plans = homeData.plans.sorted(by: <)
        case let .updateNotifyStatus(hasNotify):
            newState.hasNotify = hasNotify
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .updatePlanList(planList):
            newState.plans = planList
        case let .updateMeetList(meetList):
            newState.meetList = meetList
        case let .catchError(err):
            newState.error = err
        }
        return newState
    }
}
    
// MARK: - Data Request
extension HomeViewReactor {
    private func fetchHomeData() -> Observable<Mutation> {
                
        let fetchSchedules = fetchRecentScheduleUseCase.execute()
            .asObservable()
            .catchAndReturn(.init(plans: [], meets: []))
            .map { Mutation.updateHomeData($0) }
        
        return requestWithLoading(task: fetchSchedules)
    }
    
    private func fetchNoticationStatus() -> Observable<Mutation> {
        guard let notifyCount = UserInfoStorage.shared.userInfo?.notifyCount else {
            return .empty()
        }
        let hasNotify = notifyCount > 0
        return .just(.updateNotifyStatus(hasNotify))
    }
    
    private func uploadFCMToken() {
        guard isLogin else { return }
        uploadFCMTokenUseCase
            .executeWhenLogin()
    }
}

// MARK: - Coordination
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
        case .notify:
            return presentNotifyView()
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
            coordinator?.presentPlanDetailView(planId: id, type: .plan)
            return .empty()
        } else {
            return .just(.catchError(.midnight(.midnightReset)))
        }
    }
    
    private func presentNotifyView() -> Observable<Mutation> {
        coordinator?.presentNotifyView()
        return .empty()
    }
}

// MARK: - Premission
extension HomeViewReactor {
    private func requestNotificationPermission() -> Observable<Mutation> {
        return Observable<Mutation>.create { observer in
            self.notificationService.requestPermissions {
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - Notify
extension HomeViewReactor {
    
    // MARK: - Plan
    private func handlePlanPayload(_ payload: PlanPayload) -> Observable<Mutation> {
        print(#function, #line, "Path : #0331 ")
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
        return fetchHomeData()
    }
    
    // MARK: - Meet
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
    
    // MARK: - MidNight
    private func reloadDay() -> Observable<Mutation> {
        let planDate = currentState.plans.compactMap { $0.date }
        if planDate.contains(where: { DateManager.isPastDay(on: $0) }) {
            action.onNext(.fetchHomeData)
        }
        return .empty()
    }
}

// MARK: - Loading & Error
extension HomeViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(.unknown(error))
    }
}

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
    }
    
    enum Mutation {
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







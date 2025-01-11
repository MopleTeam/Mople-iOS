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
        case presentCalendar(date: Date)
        case presentCreateGroupView
        case presentCreatePlanView
        case responseRecentPlan(schedules: RecentPlan)
        case notifyLoadingState(_ isLoading: Bool)
        case handleHomeError(error: HomeError?)
    }
    
    struct State {
        @Pulse var plans: [Plan] = []
        @Pulse var hasMeet: Bool = false
        @Pulse var error: HomeError?
        @Pulse var isLoading: Bool = false
    }
    
    private let fetchRecentScheduleUseCase: FetchRecentPlan
    private let notificationService: NotificationService
    private let coordinator: HomeCoordination
    
    var initialState: State = State()
    
    init(fetchRecentScheduleUseCase: FetchRecentPlan,
         notificationService: NotificationService,
         coordinator: HomeCoordination) {
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
            newState.hasMeet = homeModel.hasMeet
            newState.plans = recentSchedules
        case .presentCalendar(let date):
            coordinator.pushCalendarView(lastRecentDate: date)
        case .presentCreateGroupView:
            coordinator.presentCreateGroupView()
        case .presentCreatePlanView:
            coordinator.presentCreatePlanScene()
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
    private func presentNextEvent() -> Observable<Mutation> {
        guard !currentState.plans.isEmpty,
              let lastDate = currentState.plans.last?.date else { return .empty() }
        let startOfDay = DateManager.startOfDay(lastDate)
        return .just(.presentCalendar(date: startOfDay))
    }
    
    private func presentMeetCreateView() -> Observable<Mutation> {
        coordinator.presentCreateGroupView()
        return .empty()
    }
    
    private func presentPlanCreateView() -> Observable<Mutation> {
        guard currentState.hasMeet else { return .just(.handleHomeError(error: .emptyMeet)) }
        coordinator.presentCreatePlanScene()
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







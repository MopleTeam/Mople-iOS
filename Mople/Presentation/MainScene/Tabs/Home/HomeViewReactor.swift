//
//  ScheduleViewModel.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import CoreLocation
import ReactorKit

enum HomeError: Error {
    case emptyMeet
}

final class HomeViewReactor: Reactor {

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
        case responseRecentPlan(schedules: HomeModel)
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
    private let requestRefreshFCMTokenUseCase: ReqseutRefreshFCMToken
    private let coordinator: HomeCoordination
    
    var initialState: State = State()
    
    init(fetchRecentScheduleUseCase: FetchRecentPlan,
         refreshFCMTokenUseCase: ReqseutRefreshFCMToken,
         coordinator: HomeCoordination) {
        print(#function, #line, "LifeCycle Test HomeViewReactor Created" )

        self.fetchRecentScheduleUseCase = fetchRecentScheduleUseCase
        self.requestRefreshFCMTokenUseCase = refreshFCMTokenUseCase
        self.coordinator = coordinator
        action.onNext(.requestRecentPlan)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test HomeViewReactor Deinit" )
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
            checkNotificationPermission()
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
    private func checkNotificationPermission() -> Observable<Mutation> {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { [weak self] setting in
            switch setting.authorizationStatus {
            case .authorized:
                self?.requestRefreshFCMTokenUseCase.refreshFCMToken()
                self?.requestLocationPermission()
            case .notDetermined:
                self?.requestNotificationPermission(notificationCenter)
            default:
                self?.requestLocationPermission()
            }
        }
        
        return Observable.empty()
    }
    
    
    /// 유저에게 알림 허용여부 묻기
    private func requestNotificationPermission(_ center: UNUserNotificationCenter) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (granted, error) in
            self?.registerForRemoteNotifications()
            self?.requestLocationPermission()
            print(#function, #line, "#10 : \(granted)" )
        }
    }
    
    /// 앱 진입 시 디바이스 토큰 재업로드 하기
    private func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    private func requestLocationPermission() {
        let locationManager = CLLocationManager()
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}

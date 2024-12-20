//
//  ScheduleViewModel.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import ReactorKit

struct HomeViewAction {
    var presentCreateGroupView: (() -> Void)
    var presentCreatePlanView: (([MeetSummary]) -> Void)
    var presentCalendarView: (Date) -> Void
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
    }
    
    struct State {
        @Pulse var plans: [Plan] = []
    }
    
    private let fetchRecentScheduleUseCase: FetchRecentPlan
    private let requestRefreshFCMTokenUseCase: ReqseutRefreshFCMToken
    private let homeViewAction: HomeViewAction
    
    var initialState: State = State()
    var meets: [MeetSummary] = []
    
    init(fetchRecentScheduleUseCase: FetchRecentPlan,
         refreshFCMTokenUseCase: ReqseutRefreshFCMToken,
         viewAction: HomeViewAction) {
        print(#function, #line, "LifeCycle Test HomeViewReactor Created" )

        self.fetchRecentScheduleUseCase = fetchRecentScheduleUseCase
        self.requestRefreshFCMTokenUseCase = refreshFCMTokenUseCase
        self.homeViewAction = viewAction
        action.onNext(.requestRecentPlan)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test HomeViewReactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestRecentPlan:
            return fetchRecentSchedules()
        case .createGroup:
            return .just(.presentCreateGroupView)
        case .presentCalendaer:
            return presentNextEvent()
        case .checkNotificationPermission:
            return checkNotificationPermission()
        case .createPlan:
            return .just(.presentCreatePlanView)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .responseRecentPlan(let homeModel):
            let recentSchedules = homeModel.plans.sorted(by: <)
            newState.plans = recentSchedules
            self.meets = homeModel.meetSummary
        case .presentCalendar(let date):
            homeViewAction.presentCalendarView(date)
        case .presentCreateGroupView:
            homeViewAction.presentCreateGroupView()
        case .presentCreatePlanView:
            homeViewAction.presentCreatePlanView(meets)
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
    
    private func checkNotificationPermission() -> Observable<Mutation> {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { setting in
            switch setting.authorizationStatus {
            case .authorized:
                print(#function, #line, "# 30 몇번 호출" )
                self.requestRefreshFCMTokenUseCase.refreshFCMToken()
            case .notDetermined:
                self.requestNotificationPermission(notificationCenter)
            default: break
            }
        }
        
        return Observable.empty()
    }
    
    
    /// 유저에게 알림 허용여부 묻기
    private func requestNotificationPermission(_ center: UNUserNotificationCenter) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            self.registerForRemoteNotifications()
        }
    }
    
    /// 앱 진입 시 디바이스 토큰 재업로드 하기
    private func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    private func fetchRecentSchedules() -> Observable<Mutation> {
        
        let fetchSchedules = fetchRecentScheduleUseCase.fetchRecentPlan()
            .asObservable()
            .map { Mutation.responseRecentPlan(schedules: $0) }
        
        return fetchSchedules
    }
    
    private func presentNextEvent() -> Observable<Mutation> {
        guard !currentState.plans.isEmpty,
              let lastDate = currentState.plans.last?.date else { return Observable.empty() }
        let startOfDay = DateManager.startOfDay(lastDate)
        return .just(.presentCalendar(date: startOfDay))
    }
}

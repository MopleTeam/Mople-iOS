//
//  ScheduleViewModel.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import ReactorKit

struct HomeViewAction {
    var logOut: () -> Void
    var presentNextEvent: (Date) -> Void
}

final class ScheduleViewReactor: Reactor {
    enum Action {
        case fetchRecentSchedule
        case logOutTest
        case presentCalendaer
    }
    
    enum Mutation {
        case fetchRecentScehdule(schedules: [Schedule])
    }
    
    struct State {
        @Pulse var schedules: [Schedule] = []
    }
    
    private let fetchRecentScheduleImpl: FetchRecentSchedule
    private let homeViewAction: HomeViewAction
    
    var initialState: State = State()
    
    init(fetchRecentSchedule: FetchRecentSchedule,
         viewAction: HomeViewAction) {
        self.fetchRecentScheduleImpl = fetchRecentSchedule
        self.homeViewAction = viewAction
        action.onNext(.fetchRecentSchedule)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchRecentSchedule:
            return fetchRecentSchedules()
        case .logOutTest:
            homeViewAction.logOut()
            return Observable.empty()
        case .presentCalendaer:
            presentNextEvent()
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .fetchRecentScehdule(let schedules):
            newState.schedules = schedules.sorted(by: { $0.date < $1.date })
            
            return newState
        }
    }
    
    func handleError(state: State, err: Error) -> State {
        let newState = state
        
        // 에러 처리
        
        return newState
    }
}
    

extension ScheduleViewReactor {
    private func fetchRecentSchedules() -> Observable<Mutation> {
        
        let fetchSchedules = fetchRecentScheduleImpl.fetchRecentSchedule()
            .asObservable()
            .map { Mutation.fetchRecentScehdule(schedules: $0) }
        
        return fetchSchedules
    }
    
    private func presentNextEvent() {
        guard !currentState.schedules.isEmpty,
              let lastDate = currentState.schedules.last?.date else { return }
        
        homeViewAction.presentNextEvent(lastDate)
    }
}

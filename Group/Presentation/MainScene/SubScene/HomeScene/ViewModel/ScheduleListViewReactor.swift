//
//  ScheduleViewModel.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import ReactorKit

struct HomeViewAction {
    var logOut: () -> Void
    var presentCalendar: () -> Void
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
    
    private let fetchUseCase: FetchRecentSchedule
    private let homeViewAction: HomeViewAction
    
    var initialState: State = State()
    
    init(fetchUseCase: FetchRecentSchedule,
         logOutAction: HomeViewAction) {
        self.fetchUseCase = fetchUseCase
        self.homeViewAction = logOutAction
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
            homeViewAction.presentCalendar()
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .fetchRecentScehdule(let schedules):
            newState.schedules = schedules
            
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
        
        let fetchSchedules = fetchUseCase.fetchRecentSchedule()
            .asObservable()
            .map { Mutation.fetchRecentScehdule(schedules: $0) }
        
        return fetchSchedules
    }
}

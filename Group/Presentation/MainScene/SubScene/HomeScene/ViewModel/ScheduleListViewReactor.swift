//
//  ScheduleViewModel.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import ReactorKit

struct LogOutAction {
    var logOut: () -> Void
}

final class ScheduleViewReactor: Reactor {
    enum Action {
        case fetchRecentSchedule
        case logOutTest
    }
    
    enum Mutation {
        case fetchRecentScehdule(schedules: [Schedule])
    }
    
    struct State {
        @Pulse var schedules: [Schedule] = []
    }
    
    private let fetchUseCase: FetchRecentSchedule
    private let logOutAction: LogOutAction
    
    var initialState: State = State()
    
    init(fetchUseCase: FetchRecentSchedule,
         logOutAction: LogOutAction) {
        self.fetchUseCase = fetchUseCase
        self.logOutAction = logOutAction
        action.onNext(.fetchRecentSchedule)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchRecentSchedule:
            return fetchRecentSchedules()
        case .logOutTest:
            logOutAction.logOut()
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
        
        let fetchSchedules = fetchUseCase.fetchRecent()
            .asObservable()
            .map { Mutation.fetchRecentScehdule(schedules: $0) }
        
        return fetchSchedules
    }
}

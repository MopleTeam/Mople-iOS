//
//  ScheduleViewModel.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import Foundation
import ReactorKit

final class ScheduleViewReactor: Reactor {
    enum Action {
        case fetchRecentSchedule
    }
    
    enum Mutation {
        case fetchRecentScehdule(schedules: [Schedule])
    }
    
    struct State {
        @Pulse var schedules: [Schedule] = []
    }
    
    private let fetchUseCase: FetchRecentSchedule
    
    var initialState: State = State()
    
    init(fetchUseCase: FetchRecentSchedule) {
        self.fetchUseCase = fetchUseCase
        action.onNext(.fetchRecentSchedule)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .fetchRecentScehdule(let schedules):
            newState.schedules = schedules
        }
        
        return newState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchRecentSchedule:
            fetchRecentSchedules()
        }
    }
    
    func handleError(state: State, err: Error) -> State {
        var newState = state
        
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

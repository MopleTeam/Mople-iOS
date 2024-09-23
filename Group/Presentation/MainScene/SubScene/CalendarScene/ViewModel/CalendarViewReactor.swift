//
//  CalendarViewReactor.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import ReactorKit
import UIKit

final class CalendarViewReactor: Reactor {
    enum Action {
        case fetchScheduleList
    }
    
    enum Mutation {
        case fetchScheduleList(scheduleList: [Schedule])
    }
    
    struct State {
        @Pulse var ScheduleList: [Schedule] = []
        
        var dates: [Date] {
            ScheduleList.compactMap {
                return $0.date
            }
        }
    }
        
    private let fetchUseCase: FetchRecentSchedule

    var initialState: State = State()
    
    init(fetchUseCase: FetchRecentSchedule) {
        self.fetchUseCase = fetchUseCase
        action.onNext(.fetchScheduleList)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchScheduleList:
            return fetchScheduleList()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .fetchScheduleList(let scheduleList):
            newState.ScheduleList = scheduleList
        }
        
        return newState
    }
}

extension CalendarViewReactor {
    private func fetchScheduleList() -> Observable<Mutation> {
        
        let fetchData = fetchUseCase.fetchRecent()
            .asObservable()
            .map { Mutation.fetchScheduleList(scheduleList: $0) }
        
        return fetchData
    }
}

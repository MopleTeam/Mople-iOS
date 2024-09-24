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
        case fetchData
    }
    
    enum Mutation {
        case fetchScheduleList(scheduleList: [ScheduleTableModel])
        case parseScheduleDateComponents(componentsArray: [DateComponents])
    }
    
    struct State {
        @Pulse var scheduleArray: [ScheduleTableModel] = []
        @Pulse var dateComponentsArray: [DateComponents] = []
    }
        
    private let currentCalendar = DateManager.calendar
    private let fetchUseCase: FetchRecentSchedule

    var initialState: State = State()
    
    init(fetchUseCase: FetchRecentSchedule) {
        self.fetchUseCase = fetchUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchData:
            return fetchData()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .fetchScheduleList(let scheduleList):
            newState.scheduleArray = scheduleList
        case .parseScheduleDateComponents(let componentsArray):
            newState.dateComponentsArray = componentsArray
        }
        
        return newState
    }
}

extension CalendarViewReactor {
    private func fetchData() -> Observable<Mutation> {
        let fetchData = fetchUseCase.fetchRecent().asObservable()
        
        let fetchScheduleList = fetchData
            .map { Dictionary(grouping: $0) { schedule in
                return self.currentCalendar.dateComponents([.year, .month, .day], from: schedule.date ?? Date())
            }}
            .map { $0.map { return ScheduleTableModel(dateComponents: $0.key, items: $0.value) } }
            .map { Mutation.fetchScheduleList(scheduleList: $0) }
        
        let parseDateComponents = fetchData
            .map { $0.compactMap { $0.date } }
            .map { Set($0.map { self.currentCalendar.dateComponents([.year, .month, .day], from: $0) } ) }
            .map({ Array($0) })
            .map { Mutation.parseScheduleDateComponents(componentsArray: $0) }
                    
        return Observable.concat([fetchScheduleList, parseDateComponents])
    }
}

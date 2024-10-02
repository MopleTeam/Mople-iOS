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
        case calendarHeightChanged(height: CGFloat)
        case requestPageSwitch(date: DateComponents)
        case requestScopeSwitch
        case scopeChanged(scope: ScopeType)
        case pageChanged(page: DateComponents)
        case dateSelected(date: DateComponents)
        case focusDateInWeekView(date: DateComponents)
        case sharedTableViewDate(date: DateComponents)
        case filterOutEmptySchedule
    }
    
    enum Mutation {
        case loadScheduleList(scheduleList: [ScheduleTableSectionModel])
        case loadScheduleListWithEmptySchedule(scheduleList: [ScheduleTableSectionModel])
        case loadEventList(componentsArray: [DateComponents])
        case setCalendarHeight(_ height: CGFloat)
        case switchPage(_ date: DateComponents)
        case switchScope
        case notifyChangedScope(_ scope: ScopeType)
        case notifyChangedPage(_ page: DateComponents)
        case notifySelectdDate(_ date: DateComponents)
        case notifyFocusDateInWeekView(_ date: DateComponents)
        case notifyTableViewDate(_ date: DateComponents)
    }
    
    struct State {
        @Pulse var schedules: [ScheduleTableSectionModel] = []
        @Pulse var eventDates: [DateComponents] = []
        @Pulse var calendarHeight: CGFloat?
        @Pulse var switchPage: DateComponents?
        @Pulse var switchScope: Void? = nil
        @Pulse var scope: ScopeType?
        @Pulse var changedPage: DateComponents?
        @Pulse var selectedDate: DateComponents?
        @Pulse var focusDateInWeekView: DateComponents?
        @Pulse var tableViewDate: DateComponents?
    }
        
    private let currentCalendar = DateManager.calendar
    private let fetchUseCase: FetchRecentSchedule

    var initialState: State = State()
    var todayComponents = Date().getComponents()
    
    init(fetchUseCase: FetchRecentSchedule) {
        self.fetchUseCase = fetchUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchData:
            return fetchData()
        case .calendarHeightChanged(let height):
            return .just(.setCalendarHeight(height))
        case .requestPageSwitch(let date):
            return .just(.switchPage(date))
        case .requestScopeSwitch :
            return .just(.switchScope)
        case .scopeChanged(let scope):
            return .just(.notifyChangedScope(scope))
        case .pageChanged(let page):
            return .just(.notifyChangedPage(page))
        case .dateSelected(let date):
            return presentDate(date)
        case .focusDateInWeekView(let date):
            return .just(.notifyFocusDateInWeekView(date))
        case .sharedTableViewDate(let date):
            return .just(.notifyTableViewDate(date))
        case .filterOutEmptySchedule:
            return filterOutEmptySchedule()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .loadScheduleList(let scheduleList):
            newState.schedules = scheduleList.sorted { $0.dateComponents < $1.dateComponents }
        case .loadScheduleListWithEmptySchedule(let scheduleList):
            newState.schedules = scheduleList.sorted { $0.dateComponents < $1.dateComponents }
        case .loadEventList(let componentsArray):
            newState.eventDates = componentsArray.sorted(by: { $0 < $1 })
        case .setCalendarHeight(let height):
            newState.calendarHeight = height
        case .switchPage(let date):
            newState.switchPage = date
        case .switchScope:
            newState.switchScope = ()
        case .notifyChangedScope(let scope):
            newState.scope = scope
        case .notifyChangedPage(let page):
            newState.changedPage = page
        case .notifySelectdDate(let date):
            newState.selectedDate = date
        case .notifyFocusDateInWeekView(let date):
            newState.focusDateInWeekView = date
        case .notifyTableViewDate(let date):
            newState.tableViewDate = date
        }
        return newState
    }
}

extension CalendarViewReactor {
    private func fetchData() -> Observable<Mutation> {
        let fetchData = fetchUseCase.fetchRecent().asObservable()
        
        let fetchScheduleList = fetchData
            .map { Dictionary(grouping: $0) { schedule in
                return schedule.date.getComponents()
            }}
            .map { $0.map { return ScheduleTableSectionModel(dateComponents: $0.key, items: $0.value) } }
            .map { Mutation.loadScheduleList(scheduleList: $0) }
        
        let parseDateComponents = fetchData
            .map { $0.compactMap { $0.date } }
            .map { Set($0.map { self.currentCalendar.dateComponents([.year, .month, .day], from: $0) } ) }
            .map({ Array($0) })
            .map { Mutation.loadEventList(componentsArray: $0) }
                    
        return Observable.concat([fetchScheduleList, parseDateComponents])
    }
    
    private func presentDate(_ dateComponents: DateComponents) -> Observable<Mutation> {
        
        guard !isSameAsPreviousDate(on: dateComponents) else {
            return Observable.just(Mutation.notifySelectdDate(dateComponents))
        }
        
        if hasEvent(on: dateComponents) {
            return selectedNonEmptySchedule(on: dateComponents)
        } else {
            return selectedEmptySchedule(on: dateComponents)
        }
    }
    
    private func filterOutEmptySchedule() -> Observable<Mutation> {
        let scheduleList = Observable.just(())
            .filter { _ in self.hasEmptySchedule() }
            .map { _ in Mutation.loadScheduleList(scheduleList: self.getNonEmptySchedules()) }
        
        return scheduleList
    }
    
    private func selectedNonEmptySchedule(on date: DateComponents) -> Observable<Mutation> {
        let scheduleList = Observable.just(())
            .filter { _ in self.hasEmptySchedule() }
            .map { _ in Mutation.loadScheduleList(scheduleList: self.getNonEmptySchedules()) }
            
        let presentDate = Observable.just(Mutation.notifySelectdDate(date))
        return Observable.concat([scheduleList, presentDate])
    }
    
    private func selectedEmptySchedule(on date: DateComponents) -> Observable<Mutation> {
        let scheduleListWithEmpty = Observable.just(Mutation.loadScheduleListWithEmptySchedule(scheduleList: getSchedulesWithEmpty(on: date)))
        
        let presentEmptyDate = Observable.just(Mutation.notifySelectdDate(date))
        return Observable.concat([scheduleListWithEmpty, presentEmptyDate])
    }
}

extension CalendarViewReactor {
    private func isSameAsPreviousDate(on currentDate: DateComponents) -> Bool {
        guard let selectedDate = currentState.selectedDate else { return false }
        return selectedDate == currentDate
    }
    
    private func hasEvent(on date: DateComponents) -> Bool {
        let nonEmptySchedules = getNonEmptySchedules()
        return nonEmptySchedules.contains { $0.dateComponents == date }
    }
    
    private func hasEmptySchedule() -> Bool {
        currentState.schedules.contains { schedule in
            schedule.items.contains { event in
                event is EmptySchedule
            }
        }
    }
    
    private func getNonEmptySchedules() -> [ScheduleTableSectionModel] {
        var currentScheduleList = currentState.schedules
        currentScheduleList.removeAll { sectionModel in
            sectionModel.items.contains { $0 is EmptySchedule }
        }
        
        return currentScheduleList
    }
    
    private func getSchedulesWithEmpty(on date: DateComponents) -> [ScheduleTableSectionModel] {
        guard let emptyDate = date.getDate() else { return [] }
        var nonEmptyScheduleList = getNonEmptySchedules()
        let emptyItem = EmptySchedule(date: emptyDate)
        let emptyModel = ScheduleTableSectionModel(dateComponents: date, items: [emptyItem])
        nonEmptyScheduleList.append(emptyModel)
        return nonEmptyScheduleList
    }
}

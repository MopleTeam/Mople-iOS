//
//  CalendarViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import ReactorKit

enum EventUpdateType {
    case add(Date)
    case delete(Date)
    case deleteMonth(Date)
    case update(at: Date, with :[Date])
}

protocol CalendarCommands: AnyObject {
    func updateEvent(type: EventUpdateType)
    func resetDate()
}

final class CalendarViewReactor: Reactor {
    
    enum Action {
        case fetchEventsAndHolidays
        case fetchHolidays(year: Int)
        case updateEvent(updateType: EventUpdateType)
    }
    
    enum Mutation {
        case updateEvents([Date])
        case updateHolidays([Date])
        case completedDateLoad
    }
    
    struct State {
        @Pulse var events: [Date] = []
        @Pulse var holidays: [Date] = []
        @Pulse var completedLoad: Void?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var loadedHolidayYears: Set<Int> = .init()
    
    // MARK: - UseCase
    private let fetchCalendarDatesUseCase: FetchAllPlanDate
    private let fetchHolidaysUseCase: FetchHolidays
    
    // MARK: - Delegate
    private weak var delegate: CalendarReactorDelegate?
    
    // MARK: - LifeCycle
    init(fetchCalendraDatesUseCase: FetchAllPlanDate,
         fetchHolidaysUseCase: FetchHolidays,
         delegate: CalendarReactorDelegate?) {
        self.fetchCalendarDatesUseCase = fetchCalendraDatesUseCase
        self.fetchHolidaysUseCase = fetchHolidaysUseCase
        self.delegate = delegate
        initialSetup()
    }
    
    // MARK: - Initial Setup
    private func initialSetup() {
        action.onNext(.fetchEventsAndHolidays)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchEventsAndHolidays:
            return fetchEventAndHolidayWithLoading()
        case let .fetchHolidays(year):
            return fetchHolidaysWithLoading(for: year)
        case let .updateEvent(type):
            return mergeEvent(type: type)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateEvents(dates):
            newState.events = dates.map({ DateManager.startOfDay($0) })
        case let .updateHolidays(holidays):
            newState.holidays = holidays
        case .completedDateLoad:
            newState.completedLoad = ()
        }
        
        return newState
    }
}

// MARK: - Data Request
extension CalendarViewReactor {
    
    private func fetchEvent() -> Observable<Mutation> {
        return fetchCalendarDatesUseCase.execute()
            .catchAndReturn([])
            .do(onNext: { [weak self] in
                self?.updatePlanMonthList(from: $0)
            })
            .map { Mutation.updateEvents($0) }
    }
    
    private func fetchHolidays(for year: Int?) -> Observable<Mutation> {
        guard let year else { return .empty() }
        
        return fetchHolidaysUseCase.execute(for: year)
            .do(onNext: { [weak self] _ in
                self?.markHolidayYearAsLoaded(year)
            })
            .map { $0.compactMap { $0.date } }
            .map { Mutation.updateHolidays($0) }
    }
    
    private func needsToFetchHolidays(for year: Int) -> Bool {
        return !loadedHolidayYears.contains(year)
    }
    
    private func markHolidayYearAsLoaded(_ year: Int) {
        loadedHolidayYears.insert(year)
    }
    
    private func updatePlanMonthList(from dateList: [Date]) {
        delegate?.updatePostMonthList(dateList)
    }
    
    // MARK: - Request With Loading
    
    private func fetchEventAndHolidayWithLoading() -> Observable<Mutation> {
        
        let currentYear = DateManager.todayComponents.year
        
        let fetchDateAndHolidays = Observable.zip([fetchHolidays(for: currentYear),
                                                   fetchEvent()])
            .flatMap { result -> Observable<Mutation> in
                return .from(result)
            }
 
        return .concat([requestWithLoading(task: fetchDateAndHolidays),
                        .just(.completedDateLoad)])
    }
    
    private func fetchHolidaysWithLoading(for year: Int?) -> Observable<Mutation> {
        guard let year,
              needsToFetchHolidays(for: year) else { return .empty() }
        return .concat([requestWithLoading(task: fetchHolidays(for: year)),
                        .just(.completedDateLoad)])
    }
}

// MARK: - Merge Event
extension CalendarViewReactor {
    
    /// 테이블 리스트에서 페이징처리로 들어오는 이벤트 리스트와 병합
    private func mergeEvent(type: EventUpdateType) -> Observable<Mutation> {
        var dateList = currentState.events
        
        switch type {
        case let .add(newDate):
            addPlan(with: &dateList,
                    newDate: newDate)
        case let .delete(deleteDate):
            deletePlan(with: &dateList,
                       deleteDate: deleteDate)
        case let .deleteMonth(month):
            deleteMonth(with: &dateList,
                        month: month)
        case let .update(month, monthDateList):
            updatePlan(with: &dateList,
                       at: month,
                       monthDate: monthDateList)
        }
        
        return .just(.updateEvents(dateList))
    }
    
    private func addPlan(with dateList: inout [Date], newDate: Date) {
        let startNewDate = DateManager.startOfDay(newDate)
        guard dateList.contains(where: { $0 == startNewDate }) == false else { return }
        dateList.append(startNewDate)
    }
    
    private func deletePlan(with dateList: inout [Date],
                            deleteDate: Date) {
        dateList.removeAll { date in
            return DateManager.isSameDay(date, deleteDate)
        }
    }
    
    private func updatePlan(with dateList: inout [Date],
                            at month: Date,
                            monthDate: [Date]) {
        let startUpdateDate = monthDate.compactMap { DateManager.startOfDay($0) }
        dateList.removeAll { DateManager.isSameMonth($0, month) }
        dateList.append(contentsOf: startUpdateDate)
    }
    
    private func deleteMonth(with dateList: inout [Date],
                             month: Date) {
        var datelist = currentState.events
        datelist.removeAll { DateManager.isSameMonth($0, month) }
    }
}

// MARK: - Commands
extension CalendarViewReactor: CalendarCommands {
    func updateEvent(type: EventUpdateType) {
        action.onNext(.updateEvent(updateType: type))
    }
    
    func resetDate() {
        initialSetup()
    }
}

// MARK: - Loading & Error
extension CalendarViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
}

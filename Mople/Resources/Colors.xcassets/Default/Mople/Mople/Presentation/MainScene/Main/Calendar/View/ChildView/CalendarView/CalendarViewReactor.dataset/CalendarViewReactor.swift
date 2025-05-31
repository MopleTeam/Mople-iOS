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
    case update(at: Date, with :[Date])
}

protocol CalendarCommands: AnyObject {
    func scrollToDate(on date: Date)
    func changePage(on date: Date)
    func changeScope()
    func updateEvent(type: EventUpdateType)
    func deleteMonth(month: Date)
    func resetDate()
}

final class CalendarViewReactor: Reactor {
    
    enum Action {
        enum ParentCommand {
            case scrollToDate(Date)
            case changePage(Date)
            case editDateList([Date])
            case changeScope
        }
        
        enum ChildEvent {
            case changedScope(ScopeType)
            case changeMonth(DateComponents)
            case changedPage(Date)
            case selectedDate(Date)
        }
        
        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case fetchDates
    }
    
    enum Mutation {
        case changeScope
        case changeMonthScope
        case updatePage(Date)
        case updateScrollDate(Date)
        case updateDates([Date])
    }
    
    struct State {
        @Pulse var dates: [Date] = []
        @Pulse var scrollDate: Date?
        @Pulse var page: Date?
        @Pulse var changeScope: Void?
        @Pulse var changeMonthScope: Void?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    
    // MARK: - UseCase
    private let fetchCalendarDatesUseCase: FetchAllPlanDate
    
    // MARK: - Delegate
    private weak var delegate: CalendarReactorDelegate?
    
    // MARK: - LifeCycle
    init(fetchCalendraDatesUseCase: FetchAllPlanDate,
         delegate: CalendarReactorDelegate?) {
        self.fetchCalendarDatesUseCase = fetchCalendraDatesUseCase
        self.delegate = delegate
        initialSetup()
    }
    
    // MARK: - Initial Setup
    private func initialSetup() {
        action.onNext(.fetchDates)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .parentCommand(commmand):
            return handleCommands(commmand)
        case .fetchDates:
            return fetchDates()
        case let .childEvent(action):
            return handleDelegateFromAction(action: action)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateDates(dates):
            newState.dates = dates.map({ DateManager.startOfDay($0) })
        case let .updateScrollDate(date):
            newState.scrollDate = date
        case let .updatePage(month):
            newState.page = month
        case .changeScope:
            newState.changeScope = ()
        case .changeMonthScope:
            newState.changeMonthScope = ()
        }
        
        return newState
    }
}

// MARK: - Action Handling
extension CalendarViewReactor {
    private func handleDelegateFromAction(action: Action.ChildEvent) -> Observable<Mutation> {
        switch action {
        case let .changedScope(scope):
            delegate?.updateScope(scope)
        case let .changedPage(page):
            delegate?.updatePage(page)
        case let .changeMonth(month):
            delegate?.updateMonth(month)
        case let .selectedDate(date):
            delegate?.selectedDate(date: date)
        }
        return .empty()
    }
    
    private func handleCommands(_ command: Action.ParentCommand) -> Observable<Mutation> {
        switch command {
        case let .scrollToDate(date):
            return .just(.updateScrollDate(date))
        case .changeScope:
            return .just(.changeScope)
        case let .editDateList(dateList):
            return .just(.updateDates(dateList))
        case let .changePage(month):
            return .just(.updatePage(month))
        }
    }
}

// MARK: - Data Request
extension CalendarViewReactor {
    private func fetchDates() -> Observable<Mutation> {
        let fetchDates = fetchCalendarDatesUseCase.execute()
            .catchAndReturn([])
            .flatMap { [weak self] result -> Observable<Mutation> in
                self?.updatePlanMonthList(from: result)
                let updateDate = Mutation.updateDates(result)
                let setMonthScope = Mutation.changeMonthScope
                return .from([updateDate, setMonthScope])
            }
        
        return requestWithLoading(task: fetchDates)
    }
    
    private func updatePlanMonthList(from dateList: [Date]) {
        delegate?.updatePostMonthList(dateList)
    }
}

// MARK: - Commands
extension CalendarViewReactor: CalendarCommands {
    func scrollToDate(on date: Date) {
        action.onNext(.parentCommand(.scrollToDate(date)))
    }
    
    func changePage(on date: Date) {
        action.onNext(.parentCommand(.changePage(date)))
    }
    
    func changeScope() {
        action.onNext(.parentCommand(.changeScope))
    }
    
    func deleteMonth(month: Date) {
        var datelist = currentState.dates
        
        datelist.removeAll { DateManager.isSameMonth($0, month) }
        
        action.onNext(.parentCommand(.editDateList(datelist)))
    }
    
    func updateEvent(type: EventUpdateType) {
        var dateList = currentState.dates
        
        switch type {
        case let .add(newDate):
            addPlan(with: &dateList,
                    newDate: newDate)
        case let .delete(deleteDate):
            deletePlan(with: &dateList,
                       deleteDate: deleteDate)
        case let .update(month, monthDateList):
            updatePlan(with: &dateList,
                       at: month,
                       monthDate: monthDateList)
        }
        
        action.onNext(.parentCommand(.editDateList(dateList)))
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
    
    func resetDate() {
        initialSetup()
    }
}

// MARK: - Loading & Error
extension CalendarViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
}

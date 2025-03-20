//
//  CalendarViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import ReactorKit

enum EventUpdateType {
    case update(Date)
    case delete(Date)
}

protocol CalendarCommands: AnyObject {
    func resetDate()
    func scrollToDate(on date: Date)
    func changePage(on date: Date)
    func changeScope()
    func updateEvent(type: EventUpdateType)
    func deleteMonth(month: Date)
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
            case changedCalendarHeight(CGFloat)
            case changedScope(ScopeType)
            case changeMonth(DateComponents)
            case changedPage(DateComponents)
            case selectedDate(Date)
        }
        
        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case fetchDates
    }
    
    enum Mutation {
        case changeScope
        case updatePage(Date)
        case updateScrollDate(Date)
        case updateDates([Date])
    }
    
    struct State {
        @Pulse var dates: [Date] = []
        @Pulse var scrollDate: Date?
        @Pulse var page: Date?
        @Pulse var changeScope: Void?
    }
    
    var initialState: State = State()
    
    private let fetchCalendarDatesUseCase: FetchAllPlanDate
    private weak var delegate: CalendarReactorDelegate?
    
    init(fetchCalendraDatesUseCase: FetchAllPlanDate,
         delegate: CalendarReactorDelegate) {
        self.fetchCalendarDatesUseCase = fetchCalendraDatesUseCase
        self.delegate = delegate
        initalSetup()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .parentCommand(action):
            switch action {
            case let .scrollToDate(date):
                return .just(.updateScrollDate(date))
            case .changeScope:
                return .just(.changeScope)
            case let .editDateList(dateList):
                return .just(.updateDates(dateList))
            case let .changePage(month):
                return .just(.updatePage(month))
            }
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
            newState.dates = dates
        case let .updateScrollDate(date):
            newState.scrollDate = date
        case let .updatePage(month):
            newState.page = month
        case .changeScope:
            newState.changeScope = ()
        }
        
        return newState
    }
    
    private func handleDelegateFromAction(action: Action.ChildEvent) -> Observable<Mutation> {
        switch action {
        case let .changedCalendarHeight(height):
            delegate?.updateCalendarHeight(height)
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
    
    private func initalSetup() {
        action.onNext(.fetchDates)
    }
}

extension CalendarViewReactor {
    private func fetchDates() -> Observable<Mutation> {
        let fetchDates = fetchCalendarDatesUseCase.execute()
            .debug("#0320")
            .asObservable()
            .catchAndReturn([])
            .map { [weak self] in
                self?.updatePlanMonthList(from: $0)
                $0.forEach { print(#function, #line, "#0320 스케줄 일정 : \($0)" ) }
                return Mutation.updateDates($0)
            }
        
        return requestWithLoading(task: fetchDates)
    }
    
    private func updatePlanMonthList(from dateList: [Date]) {
        let monthList = dateList.compactMap { $0.toMonthComponents().toDate() }
        let deduplicatedMonthList = Set(monthList)
        delegate?.updatePlanMonthList(Array(deduplicatedMonthList))
    }
}

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
        case let .update(newDate):
            updatePlan(&dateList, newDate: newDate)
        case let .delete(deleteDate):
            deletePlan(&dateList, deleteDate: deleteDate)
        }
        
        action.onNext(.parentCommand(.editDateList(dateList)))
    }
    
    private func updatePlan(_ dateList: inout [Date], newDate: Date) {
        guard dateList.contains(where: { $0 == newDate }) == false else { return }
        dateList.append(newDate)
    }
    
    private func deletePlan(_ dateList: inout [Date], deleteDate: Date) {
        dateList.removeAll { $0 == deleteDate }
    }
    
    func resetDate() {
        initalSetup()
    }
}

extension CalendarViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
}

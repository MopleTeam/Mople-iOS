//
//  CalendarViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import ReactorKit

protocol CalendarCommands: AnyObject {
    func scrollToDate(on date: Date)
}

final class CalendarViewReactor: Reactor {
    
    enum Action {
        enum ParentCommand {
            case scrollToDate(Date)
        }
        
        enum ChildEvent {
            case changedCalendarHeight(CGFloat)
            case changedScope(ScopeType)
            case changedPage(DateComponents)
            case selectedDate(Date)
        }
        
        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case fetchDates
    }
    
    enum Mutation {
        enum ParentRequest {
            case updatePlanMonth([DateComponents])
        }
        
        case updateScrollDate(Date)
        case updateDates([Date])
        case requestParent(ParentRequest)
    }
    
    struct State {
        @Pulse var dates: [Date] = []
        @Pulse var scrollDate: Date?
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
        case let .requestParent(request):
            handleDelegateFromMutation(state: &newState,
                                       request: request)
        case let .updateScrollDate(date):
            newState.scrollDate = date
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
        case let .selectedDate(date):
            delegate?.selectedDate(date: date)
        }
        return .empty()
    }
    
    private func handleDelegateFromMutation(state: inout State,
                                            request: Mutation.ParentRequest) {
        switch request {
        case let .updatePlanMonth(monthList):
            delegate?.updatePlanMonthList(monthList)
        }
    }
    
    private func initalSetup() {
        action.onNext(.fetchDates)
    }
}

extension CalendarViewReactor {
    private func fetchDates() -> Observable<Mutation> {
        let fetchDates = fetchCalendarDatesUseCase.execute()
            .asObservable()
            .flatMap { [weak self] dateList -> Observable<Mutation> in
                guard let self else { return .empty() }
                let updateDateList = Mutation.updateDates(dateList)
                let updateMonthList = parseMonthList(from: dateList)
                return .of(updateDateList, updateMonthList)
            }
        
        return requestWithLoading(task: fetchDates)
    }
    
    private func parseMonthList(from dateList: [Date]) -> Mutation {
        let monthList = dateList.map { $0.toMonthComponents() }
        let removeDuplicateMonth = Set(monthList)
        return .requestParent(
            .updatePlanMonth(Array(removeDuplicateMonth))
        )
    }
}

extension CalendarViewReactor: CalendarCommands {
    func scrollToDate(on date: Date) {
        action.onNext(.parentCommand(.scrollToDate(date)))
    }
}

extension CalendarViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
}

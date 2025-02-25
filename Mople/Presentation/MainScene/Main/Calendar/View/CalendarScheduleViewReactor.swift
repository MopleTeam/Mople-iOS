//
//  CalendarViewReactor.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import ReactorKit

protocol CalendarReactorDelegate: AnyObject, ChildLoadingDelegate {
    func updatePage(_ month: DateComponents)
    func updatePlanMonthList(_ list: [DateComponents])
    func updateCalendarHeight(_ height: CGFloat)
    func updateScope(_ scope: ScopeType)
    func selectedDate(date: Date)
}

protocol SchduleListReactorDelegate: AnyObject, ChildLoadingDelegate {
    func scrollToDate(date: Date)
}

final class CalendarScheduleViewReactor: Reactor, LifeCycleLoggable {
    
    typealias ScopeChangeType = CalendarViewController.ScopeChangeType
    
    enum Action {
        enum CalendarActions {
            case changedPage(DateComponents)
        }
        
        case calendarAction(CalendarActions)
        
        case calendarHeightChanged(CGFloat)
        case requestPageSwitch(dateComponents: DateComponents)
        case requestScopeSwitch(type: ScopeChangeType)
        case scopeChanged(ScopeType)
        case pageChanged(page: DateComponents)
        case dateSelected(selectDate: (selectedDate: Date?, isScroll: Bool))
        case sharedTableViewDate(date: Date)
        case requestPresentEvent(lastRecentDate: Date)
        case tableViewInteracting(isScroll: Bool)
    }
    
    enum Mutation {
        enum CalendarEvents {
            case updatePage(DateComponents)
        }
        
        case calendarEvent(CalendarEvents)
        
        case switchPage(_ dateComponents: DateComponents)

        
        case loadScheduleList(scheduleList: [ScheduleListSectionModel])
        case loadEventDateList(eventDateList: [Date])
        case setCalendarHeight(_ height: CGFloat)
        case switchScope(_ type: ScopeChangeType)
        case notifyChangedScope(_ scope: ScopeType)
        case notifyChangedPage(_ page: DateComponents)
        case notifySelectdDate(_ selectDate: (selectedDate: Date?, isScroll: Bool)?)
        case notifyTableViewDate(_ date: Date)
        case notifyPresentEvent(_ dateComponents: Date?)
        case notifyLoadingState(_ isLoading: Bool)
        case notifyTableViewInteracting(_ isScroll: Bool)
    }
    
    struct State {
        @Pulse var schedules: [ScheduleListSectionModel] = []
        @Pulse var events: [Date] = []
        @Pulse var calendarHeight: CGFloat?
        @Pulse var switchPage: DateComponents?
        @Pulse var switchScope: ScopeChangeType? = nil
        @Pulse var scope: ScopeType = .month
        @Pulse var changedPage: DateComponents?
        @Pulse var selectedDate: (selectedDate: Date?, isScroll: Bool)?
        @Pulse var tableViewDate: Date?
        @Pulse var presentDate: Date?
        @Pulse var isLoading: Bool = false
        @Pulse var isTableViewInteracting: Bool = false
    }
        
    private let fetchUseCase: FetchPlanList

    var initialState: State = State()
    
    // MARK: - Commands
    public weak var calendarCommands: CalendarCommands?
    public weak var scheduleListCommands: ScheduleListCommands?
    
    // MARK: - LifeCycle
    init(fetchUseCase: FetchPlanList) {
        self.fetchUseCase = fetchUseCase
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .calendarAction(action):
            return handleCalendarAction(action)
            

        case .calendarHeightChanged(let height):
            return .just(.setCalendarHeight(height))
        case .requestPageSwitch(let date):
            return .just(.switchPage(date))
        case .requestScopeSwitch(let type) :
            return .just(.switchScope(type))
        case .scopeChanged(let scope):
            return .just(.notifyChangedScope(scope))
        case .pageChanged(let page):
            return .just(.notifyChangedPage(page))
        case .dateSelected(let selectDate):
            return syncDateToTable(on: selectDate)
        case .sharedTableViewDate(let date):
            return .just(.notifyTableViewDate(date))
        case .requestPresentEvent(let lastRecentDate):
            return syncDate(on: lastRecentDate)
        case .tableViewInteracting(let isScroll):
            return .just(.notifyTableViewInteracting(isScroll))
        }
    }
    
    private func handleCalendarAction(_ action: Action.CalendarActions) -> Observable<Mutation> {
        switch action {
        case let .changedPage(page):
            return .just(.calendarEvent(.updatePage(page)))
        }
    }
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .calendarEvent(event):
            handleCalendarEvent(state: &newState,
                                event: event)
            
            
            
        case .loadScheduleList(let scheduleList):
            newState.schedules = scheduleList.sorted(by: <)
        case .loadEventDateList(let eventList):
            newState.events = eventList.sorted()
        case .setCalendarHeight(let height):
            newState.calendarHeight = height
        case .switchPage(let date):
            newState.switchPage = date
        case .switchScope(let type):
            newState.switchScope = type
        case .notifyChangedScope(let scope):
            newState.scope = scope
        case .notifyChangedPage(let page):
            newState.changedPage = page
        case .notifySelectdDate(let selectDate):
            newState.selectedDate = selectDate
        case .notifyTableViewDate(let date):
            newState.tableViewDate = date
        case .notifyPresentEvent(let date):
            newState.presentDate = date
        case .notifyLoadingState(let isLoading):
            newState.isLoading = isLoading
        case .notifyTableViewInteracting(let Enabled):
            newState.isTableViewInteracting = Enabled
        }
        return newState
    }
    
    private func handleCalendarEvent(state: inout State, event: Mutation.CalendarEvents) {
        switch event {
        case let .updatePage(page):
            state.changedPage = page
        }
    }
}

extension CalendarScheduleViewReactor {
    
    /// 홈뷰에서 표시된 마지막 날짜가 넘어옴
    /// 캘린더뷰, 테이블뷰로 공유
    private func syncDate(on lastRecentDate: Date) -> Observable<Mutation> {
        guard !currentState.schedules.isEmpty,
              currentState.schedules.contains(where: { $0.date == lastRecentDate }) else { return Observable.empty()}
        
        return Observable.just(Mutation.notifyPresentEvent(lastRecentDate))
    }
    
    /// 캘린더 선택 날짜 일정 테이블뷰로 공유
    private func syncDateToTable(on selectDate: (selectedDate: Date?, isScroll: Bool)) -> Observable<Mutation> {
        guard !currentState.isTableViewInteracting else { return Observable.empty() }
        return Observable.just(Mutation.notifySelectdDate(selectDate))
    }
}

extension CalendarScheduleViewReactor: CalendarReactorDelegate {
    func updateCalendarHeight(_ height: CGFloat) {
        action.onNext(.calendarHeightChanged(height))
    }
    
    func updateScope(_ scope: ScopeType) {
        action.onNext(.scopeChanged(scope))
    }
    
    func updatePlanMonthList(_ list: [DateComponents]) {
        scheduleListCommands?.updatePlanMonthList(list)
    }
    
    func updatePage(_ month: DateComponents) {
        action.onNext(.calendarAction(.changedPage(month)))
        scheduleListCommands?.moveToPage(on: month)
    }
    
    func selectedDate(date: Date) {
        scheduleListCommands?.selectedDate(on: date)
    }
}

extension CalendarScheduleViewReactor: SchduleListReactorDelegate {
    func scrollToDate(date: Date) {
        calendarCommands?.scrollToDate(on: date)
    }
}

extension CalendarScheduleViewReactor: ChildLoadingDelegate {
    func updateLoadingState(_ isLoading: Bool, index: Int) {
        
    }
    
    func catchError(_ error: any Error, index: Int) {
        
    }
}



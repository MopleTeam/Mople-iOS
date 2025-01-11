//
//  CalendarViewReactor.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import ReactorKit
import UIKit

final class CalendarViewReactor: Reactor, LifeCycleLoggable {
    
    typealias SelectDate = CalendarViewController.SelectDate
    typealias ScopeChangeType = CalendarViewController.ScopeChangeType
    
    enum Action {
        case fetchData
        case calendarHeightChanged(height: CGFloat)
        case requestPageSwitch(dateComponents: DateComponents)
        case requestScopeSwitch(type: ScopeChangeType)
        case scopeChanged(scope: ScopeType)
        case pageChanged(page: DateComponents)
        case dateSelected(selectDate: SelectDate)
        case sharedTableViewDate(date: Date)
        case requestPresentEvent(lastRecentDate: Date)
        case tableViewInteracting(isScroll: Bool)
    }
    
    enum Mutation {
        case loadScheduleList(scheduleList: [PlanTableSectionModel])
        case loadEventDateList(eventDateList: [Date])
        case setCalendarHeight(_ height: CGFloat)
        case switchPage(_ dateComponents: DateComponents)
        case switchScope(_ type: ScopeChangeType)
        case notifyChangedScope(_ scope: ScopeType)
        case notifyChangedPage(_ page: DateComponents)
        case notifySelectdDate(_ selectDate: SelectDate?)
        case notifyTableViewDate(_ date: Date)
        case notifyPresentEvent(_ dateComponents: Date?)
        case notifyLoadingState(_ isLoading: Bool)
        case notifyTableViewInteracting(_ isScroll: Bool)
    }
    
    struct State {
        @Pulse var schedules: [PlanTableSectionModel] = []
        @Pulse var events: [Date] = []
        @Pulse var calendarHeight: CGFloat?
        @Pulse var switchPage: DateComponents?
        @Pulse var switchScope: ScopeChangeType? = nil
        @Pulse var scope: ScopeType = .month
        @Pulse var changedPage: DateComponents?
        @Pulse var selectedDate: SelectDate?
        @Pulse var tableViewDate: Date?
        @Pulse var presentDate: Date?
        @Pulse var isLoading: Bool = false
        @Pulse var isTableViewInteracting: Bool = false
    }
        
    private let fetchUseCase: FetchPlanList

    var initialState: State = State()
    
    init(fetchUseCase: FetchPlanList) {
        self.fetchUseCase = fetchUseCase
        logLifeCycle()
        action.onNext(.fetchData)
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchData:
            return fetchData()
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
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
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
}

extension CalendarViewReactor {
    
    /// 스케줄 데이터 및 이벤트 목록 얻기
    private func fetchData() -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))

        let fetchAndProcess = fetchUseCase.fetchPlanList()
            .asObservable()
            .map { schedules -> (scheduleList: [PlanTableSectionModel], eventDateList: [Date]) in
                let scheduleList = self.makeTableSectionModels(schedules)
                let eventDateList = self.makeEventList(schedules)
                return (scheduleList, eventDateList)
            }
            .flatMap { result -> Observable<Mutation> in
                let scheduleListMutation = Mutation.loadScheduleList(scheduleList: result.scheduleList)
                let eventDateListMutation = Mutation.loadEventDateList(eventDateList: result.eventDateList)
                return Observable.of(scheduleListMutation, eventDateListMutation)
            }
    
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart, fetchAndProcess, loadingStop])
    }
    
    /// 홈뷰에서 표시된 마지막 날짜가 넘어옴
    /// 캘린더뷰, 테이블뷰로 공유
    private func syncDate(on lastRecentDate: Date) -> Observable<Mutation> {
        guard !currentState.schedules.isEmpty,
              currentState.schedules.contains(where: { $0.date == lastRecentDate }) else { return Observable.empty()}
        
        return Observable.just(Mutation.notifyPresentEvent(lastRecentDate))
    }
    
    /// 캘린더 선택 날짜 일정 테이블뷰로 공유
    private func syncDateToTable(on selectDate: SelectDate) -> Observable<Mutation> {
        guard !currentState.isTableViewInteracting else { return Observable.empty() }
        return Observable.just(Mutation.notifySelectdDate(selectDate))
    }
}

// MARK: - Helper
extension CalendarViewReactor {
    
    
    /// 서버로부터 전달된 일정 데이터를 테이블뷰 모델로 전환
    /// - Parameter schedules: 서버에서 받아온 일정 데이터
    /// - Returns: 일정 데이터를 일정별로 나누어서 리턴
    private func makeTableSectionModels(_ schedules: [Plan]) -> [PlanTableSectionModel] {
        let grouped = Dictionary(grouping: schedules) { schedule -> Date? in
            return schedule.startOfDate
        }
        return grouped.map { PlanTableSectionModel(date: $0.key, items: $0.value) }
    }
    
    #warning("날짜 중복검사 시에는 날짜의 시작시간으로 초기화하는 것이 옳다. (startOfDay)")
    /// 서버로부터 전달된 일정 데이터에서 이벤트만 추출
    /// - Returns: 중복값을 제거 후 전달
    private func makeEventList(_ schedules: [Plan]) -> [Date] {
        let eventArray = schedules.compactMap { $0.startOfDate }
        let withOutDuplicate = Set(eventArray)
        return Array(withOutDuplicate)
    }
}


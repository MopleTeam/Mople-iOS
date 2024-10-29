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
        case requestPageSwitch(dateComponents: DateComponents)
        case requestScopeSwitch(type: ScopeChangeType)
        case scopeChanged(scope: ScopeType)
        case pageChanged(page: DateComponents)
        case dateSelected(dateComponents: DateComponents)
        case sharedTableViewDate(dateComponents: DateComponents)
        case requestPresentEvent(lastRecentDate: Date)
    }
    
    enum Mutation {
        case loadScheduleList(scheduleList: [ScheduleTableSectionModel])
        case loadEventDateList(eventDateList: [Date])
        case setCalendarHeight(_ height: CGFloat)
        case switchPage(_ dateComponents: DateComponents)
        case switchScope(_ type: ScopeChangeType)
        case notifyChangedScope(_ scope: ScopeType)
        case notifyChangedPage(_ page: DateComponents)
        case notifySelectdDate(_ dateComponents: DateComponents?)
        case notifyTableViewDate(_ dateComponents: DateComponents)
        case notifyPresentEvent(_ dateComponents: DateComponents?)
        case notifyLoadingState(_ isLoading: Bool)
    }
    
    struct State {
        @Pulse var schedules: [ScheduleTableSectionModel] = []
        @Pulse var events: [Date] = []
        @Pulse var calendarHeight: CGFloat?
        @Pulse var switchPage: DateComponents?
        @Pulse var switchScope: ScopeChangeType? = nil
        @Pulse var scope: ScopeType?
        @Pulse var changedPage: DateComponents?
        @Pulse var selectedDate: DateComponents?
        @Pulse var tableViewDate: DateComponents?
        @Pulse var presentDate: DateComponents?
        @Pulse var isLoading: Bool = false
    }
        
    private let fetchUseCase: FetchSchedule

    var initialState: State = State()
    
    init(fetchUseCase: FetchSchedule) {
        self.fetchUseCase = fetchUseCase
        action.onNext(.fetchData)
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
        case .dateSelected(let date):
            return presentTableDate(on: date)
        case .sharedTableViewDate(let date):
            return .just(.notifyTableViewDate(date))
        case .requestPresentEvent(let lastRecentDate):
            return presentDate(on: lastRecentDate.getComponents())
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .loadScheduleList(let scheduleList):
            newState.schedules = scheduleList.sorted { $0.dateComponents < $1.dateComponents }
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
        case .notifySelectdDate(let date):
            newState.selectedDate = date
        case .notifyTableViewDate(let date):
            newState.tableViewDate = date
        case .notifyPresentEvent(let date):
            newState.presentDate = date
        case .notifyLoadingState(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
}

extension CalendarViewReactor {
    
    /// 스케줄 데이터 및 이벤트 목록 얻기
    private func fetchData() -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))

        let fetchAndProcess = fetchUseCase.fetchScheduleList()
            .asObservable()
            .map { schedules -> (scheduleList: [ScheduleTableSectionModel], eventDateList: [Date]) in
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
    
    /// 캘린더 날짜 선택 or 월 -> 주 변경 시 테이블에게 표시할 날짜 알려주기
    private func presentTableDate(on dateComponents: DateComponents) -> Observable<Mutation> {
        
        guard !isSameAsPreviousDate(on: dateComponents) else {
            return Observable.just(Mutation.notifySelectdDate(dateComponents))
        }
        
        if hasEvent(on: dateComponents) {
            return selectedNonEmptySchedule(on: dateComponents)
        } else {
            return selectedEmptySchedule(on: dateComponents)
        }
    }
    
    /// 현재 테이블뷰에서 빈 스케줄이 있다면 제거하기
    /// 빈 스케줄 : 이벤트가 없는 날짜 선택 시 없음을 알려주는 셀 타입의 모델
    private func selectedNonEmptySchedule(on date: DateComponents) -> Observable<Mutation> {
        let scheduleList = Observable.just(())
            .filter { _ in self.hasEmptySchedule() }
            .map { _ in Mutation.loadScheduleList(scheduleList: self.cleanUpEmptyModel()) }
        
        let presentDate = Observable.just(Mutation.notifySelectdDate(date))
        return Observable.concat([scheduleList, presentDate])
    }
    
    /// 빈 스케줄 생성하기
    private func selectedEmptySchedule(on date: DateComponents) -> Observable<Mutation> {
        let scheduleListWithEmpty = Observable.just(())
            .map { _ in self.hasEmptySchedule() }
            .map {
                let schedule = self.getSchedulesWithEmpty(on: date, hasEmptyModel: $0)
                return Mutation.loadScheduleList(scheduleList: schedule)
            }
        
        let presentEmptyDate = Observable.just(Mutation.notifySelectdDate(date))
        return Observable.concat([scheduleListWithEmpty, presentEmptyDate])
    }
    
    // 홈뷰에서 표시된 마지막 날짜가 넘어옴
    private func presentDate(on lastRecentDate: DateComponents) -> Observable<Mutation> {
        guard !currentState.schedules.isEmpty,
              currentState.schedules.contains(where: { $0.dateComponents == lastRecentDate }) else { return Observable.empty()}
        
        return Observable.just(Mutation.notifyPresentEvent(lastRecentDate))
    }
}

// MARK: - Helper
extension CalendarViewReactor {
    
    
    /// 서버로부터 전달된 일정 데이터를 테이블뷰 모델로 전환
    /// - Parameter schedules: 서버에서 받아온 일정 데이터
    /// - Returns: 일정 데이터를 일정별로 나누어서 리턴
    private func makeTableSectionModels(_ schedules: [Schedule]) -> [ScheduleTableSectionModel] {
        let grouped = Dictionary(grouping: schedules) { $0.date.getComponents() }
        return grouped.map { ScheduleTableSectionModel(dateComponents: $0.key, items: $0.value) }
    }
    
    #warning("날짜 중복검사 시에는 날짜의 시작시간으로 초기화하는 것이 옳다. (startOfDay)")
    /// 서버로부터 전달된 일정 데이터에서 이벤트만 추출
    /// - Returns: 중복값을 제거 후 전달
    private func makeEventList(_ schedules: [Schedule]) -> [Date] {
        return Array(Set(schedules.map({ DateManager.calendar.startOfDay(for: $0.date) })))
    }
    
    /// 현재 선택된 날짜와 같은 날짜인지 구별하기
    private func isSameAsPreviousDate(on currentDate: DateComponents) -> Bool {
        guard let selectedDate = currentState.selectedDate else { return false }
        return selectedDate == currentDate
    }
    
    /// 선택된 날짜가 스케줄 날짜에 포함되어 있는지 구별하기
    private func hasEvent(on date: DateComponents) -> Bool {
        return currentState.schedules.contains { $0.dateComponents == date }
    }
    
    /// 표시되고 있는 스케줄에서 빈 스케줄이 있는지 구별하기
    private func hasEmptySchedule() -> Bool {
        currentState.schedules.contains { schedule in
            schedule.items.contains { event in
                event is EmptySchedule
            }
        }
    }

    /// 스케줄 리스트에 빈 스케줄 추가하기
    /// - Parameters:
    ///   - date: 추가할 빈 스케줄 날짜
    ///   - hasEmptyModel: 현재 스케줄 리스트에 빈 스케줄이 있는지
    private func getSchedulesWithEmpty(on date: DateComponents, hasEmptyModel: Bool) -> [ScheduleTableSectionModel] {
        guard let emptyDate = date.getDate() else { return [] }
        let emptyItem = EmptySchedule(date: emptyDate)
        let emptyModel = ScheduleTableSectionModel(dateComponents: date, items: [emptyItem])
        var schedules = hasEmptyModel ? cleanUpEmptyModel() : currentState.schedules
        schedules.append(emptyModel)
        return schedules
    }
    
    /// 빈 스케줄 비우기
    private func cleanUpEmptyModel() -> [ScheduleTableSectionModel] {
        var presentList = currentState.schedules
        presentList.removeAll { $0.items.contains { $0 is EmptySchedule } }
        return presentList
    }
}


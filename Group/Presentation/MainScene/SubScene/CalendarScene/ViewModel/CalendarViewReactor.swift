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
        case requestNextEvent(recentEventCount: Int)
    }
    
    enum Mutation {
        case loadScheduleList(scheduleList: [ScheduleTableSectionModel])
        case loadScheduleListWithEmptySchedule(scheduleList: [ScheduleTableSectionModel])
        case setCalendarHeight(_ height: CGFloat)
        case switchPage(_ dateComponents: DateComponents)
        case switchScope(_ type: ScopeChangeType)
        case notifyChangedScope(_ scope: ScopeType)
        case notifyChangedPage(_ page: DateComponents)
        case notifySelectdDate(_ dateComponents: DateComponents?)
        case notifyTableViewDate(_ dateComponents: DateComponents)
        case notifyNextEvent(_ dateComponents: DateComponents?)
        case notifyLoadingState(_ isLoading: Bool)
    }
    
    struct State {
        @Pulse var schedules: [ScheduleTableSectionModel] = []
        @Pulse var eventDates: [DateComponents] = []
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
    var todayComponents = Date().getComponents()
    var models: [ScheduleTableSectionModel] = []
    var events: [DateComponents] = []
    
    init(fetchUseCase: FetchSchedule) {
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
        case .requestNextEvent(let recentEventCount):
            return presentNextDate(count: recentEventCount)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .loadScheduleList(let scheduleList):
            self.models = scheduleList.sorted { $0.dateComponents < $1.dateComponents }
            self.events = self.models.map({ $0.dateComponents })
            newState.schedules = self.models
            newState.eventDates = self.events
        case .loadScheduleListWithEmptySchedule(let scheduleList):
            newState.schedules = scheduleList.sorted { $0.dateComponents < $1.dateComponents }
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
        case .notifyNextEvent(let date):
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

        let scheduleArray = fetchUseCase.fetchScheduleList()
            .asObservable()
            .map { Dictionary(grouping: $0) { schedule in
                return schedule.date.getComponents()
            }}
            .map { $0.map { return ScheduleTableSectionModel(dateComponents: $0.key, items: $0.value) } }
            .map { Mutation.loadScheduleList(scheduleList: $0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart, scheduleArray, loadingStop])
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
            .map { _ in Mutation.loadScheduleList(scheduleList: self.models) }
            
        let presentDate = Observable.just(Mutation.notifySelectdDate(date))
        return Observable.concat([scheduleList, presentDate])
    }
    
    /// 빈 스케줄 생성하기
    private func selectedEmptySchedule(on date: DateComponents) -> Observable<Mutation> {
        let scheduleListWithEmpty = Observable
            .just(Mutation.loadScheduleListWithEmptySchedule(scheduleList: getSchedulesWithEmpty(on: date)))
        
        let presentEmptyDate = Observable.just(Mutation.notifySelectdDate(date))
        return Observable.concat([scheduleListWithEmpty, presentEmptyDate])
    }
    
    private func presentNextDate(count recentEventCount: Int) -> Observable<Mutation> {
        var presentDate: DateComponents?
        
        // 같은 경우
        // 더 큰 경우
        // 작은 경우
        switch recentEventCount {
        case events.count:
            presentDate = events.last
        case ..<events.count:
            presentDate = events[recentEventCount]
        default:
            print(#function, #line, "데이터가 들어오지 않은 상태" )
            return Observable.empty()
        }
        
        print(#function, #line, "presnetDate : \(presentDate)" )
        
        return Observable.just(Mutation.notifyNextEvent(presentDate))
    }
}

// MARK: - Helper
extension CalendarViewReactor {
    
    /// 현재 선택된 날짜와 같은 날짜인지 구별하기
    private func isSameAsPreviousDate(on currentDate: DateComponents) -> Bool {
        guard let selectedDate = currentState.selectedDate else { return false }
        return selectedDate == currentDate
    }
    
    /// 선택된 날짜가 스케줄 날짜에 포함되어 있는지 구별하기
    private func hasEvent(on date: DateComponents) -> Bool {
        return self.models.contains { $0.dateComponents == date }
    }
    
    /// 표시되고 있는 스케줄에서 빈 스케줄이 있는지 구별하기
    private func hasEmptySchedule() -> Bool {
        currentState.schedules.contains { schedule in
            schedule.items.contains { event in
                event is EmptySchedule
            }
        }
    }

    /// 표시되고 있는 스케줄에 빈 스케줄 추가하기
    private func getSchedulesWithEmpty(on date: DateComponents) -> [ScheduleTableSectionModel] {
        guard let emptyDate = date.getDate() else { return [] }
        var nonEmptyScheduleList = self.models
        let emptyItem = EmptySchedule(date: emptyDate)
        let emptyModel = ScheduleTableSectionModel(dateComponents: date, items: [emptyItem])
        nonEmptyScheduleList.append(emptyModel)
        return nonEmptyScheduleList.sorted { $0.dateComponents < $1.dateComponents }
    }
}

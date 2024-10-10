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
        case requestNextEvent(lastRecentDate: Date)
    }
    
    enum Mutation {
        case loadScheduleList(scheduleList: [ScheduleTableSectionModel])
        case loadEventDateList(eventDateList: [DateComponents])
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
    var eventDates: [DateComponents] = []
    
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
        case .requestNextEvent(let lastRecentDate):
            return presentNextDate(on: lastRecentDate)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .loadScheduleList(let scheduleList):
            self.models = scheduleList.sorted { $0.dateComponents < $1.dateComponents }
            newState.schedules = self.models
        case .loadEventDateList(let eventDates):
            self.eventDates = eventDates.sorted(by: { $0 < $1 })
            newState.eventDates = self.eventDates
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

        let fetchAndProcess = fetchUseCase.fetchScheduleList()
            .asObservable()
             .map { schedules -> (scheduleList: [ScheduleTableSectionModel], eventDateList: [DateComponents]) in
                 let grouped = Dictionary(grouping: schedules) { $0.date.getComponents() }
                 let scheduleList = grouped.map { ScheduleTableSectionModel(dateComponents: $0.key, items: $0.value) }
                 let eventDateList = Array(grouped.keys)
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
    
    func tsettest() {
        let observable1 = Observable.of(1, 2, 3)
        
        let test = observable1.map { return "Number: \($0)" }
        
        let flatMapped = observable1.flatMap { number -> Observable<String> in
            return Observable.of("Number: \(number)")
        }

        test.subscribe(onNext: { value in
            print(value)
        })
        
        flatMapped.subscribe(onNext: { value in
            print(value)
        })
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
    
    // 홈뷰에서 표시된 마지막 날짜가 넘어옴
    //
    private func presentNextDate(on lastRecentDate: Date) -> Observable<Mutation> {
        guard !eventDates.isEmpty else { return Observable.empty() }
        
        guard let lastRecentDate = eventDates.filter({
            let lastRecentDate = lastRecentDate.getComponents()
            return $0 == lastRecentDate
        }).first else { return Observable.empty() }
        
        return Observable.just(Mutation.notifyNextEvent(lastRecentDate))
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

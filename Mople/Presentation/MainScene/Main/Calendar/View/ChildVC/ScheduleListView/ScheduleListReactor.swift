//
//  ScheduleReactor.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import ReactorKit

protocol ScheduleListCommands: AnyObject {
    func resetPlanList()
    func planUpdateWhenMidnight()
    func setInitalList(with list: [Date])
    func fetchMonthPlan(on month: Date)
    func loadMonthlyPlan(on month: Date)
    func selectedDate(on date: Date)
    func editMeet(payload: MeetPayload)
    func editPlan(payload: PlanPayload)
    func editReview(payload: ReviewPayload)
}

enum ScheduleFetchType {
    case next
    case previous
}

enum LoadState {
    case all
    case previous
    case next
    case none
}

final class ScheduleListReactor: Reactor {
    
    enum Action {
        enum ParentCommand {
            case resetPlan
            case selectedDate(Date)
            case loadMonthlyPlan(Date)
            case loadMorePlan(on: Date, type: ScheduleFetchType)
            case editPlanList([MonthlyPlan])
            case reloadMonth([Date])
        }
        
        enum ChildEvent {
            case scrollToDate(Date)
            case selectedPlan(MonthlyPlan)
        }
        
        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case getMorePlan(ScheduleFetchType)
    }
    
    enum Mutation {
        case updateNextPlan([MonthlyPlan])
        case updateSelectedDate(Date)
        case updatePreviousPlan([MonthlyPlan])
        case initalPlan([MonthlyPlan])
        case resetPlan
    }
    
    struct State {
        @Pulse var planList: [MonthlyPlan] = []
        @Pulse var selectedDate: Date?
        @Pulse var previousPlanList: [MonthlyPlan] = []
        @Pulse var reset: Void?
    }
    
    var initialState: State = State()
    
    // MARK: - 유즈케이스
    private let fetchMonthlyPlanUseCase: FetchMonthlyPlan
    
    // MARK: - 대리자
    private weak var delegate: SchduleListReactorDelegate?
    
    // MARK: - 요청날짜 데이터
    private var currentMonth: Date?
    private var initalDateList: [Date] = []
    private var monthDateList: [Date] = []
    private var loadedDateList: [Date] = []
    private var lastLoadMonth: Date?
    private var isLoading: Bool = false
    private(set) var loadState: LoadState = .none
    
    // MARK: - LifeCylce
    init(fetchMonthlyPlanUseCase: FetchMonthlyPlan,
         delegate: SchduleListReactorDelegate) {
        self.fetchMonthlyPlanUseCase = fetchMonthlyPlanUseCase
        self.delegate = delegate
    }
    
    // MARK: - 상태 변경
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .parentCommand(command):
            return handleParentCommand(command)
        case let .childEvent(event):
            return handleChildEvent(event)
        case let .getMorePlan(type):
            guard let lastLoadMonth else { return .empty() }
            return moreFetchMonthlyPlan(on: lastLoadMonth,
                                        type: type)
        }
    }
    
    private func handleParentCommand(_ command: Action.ParentCommand) -> Observable<Mutation> {
        switch command {
        case let .loadMonthlyPlan(month):
            return fetchInitialPlans(with: month)
        case let .loadMorePlan(month,
                               fetchType):
            return moreFetchMonthlyPlan(on: month,
                                        type: fetchType)
        case let .selectedDate(date):
            return .just(.updateSelectedDate(date))
        case .resetPlan:
            return .just(.resetPlan)
        case let .editPlanList(planList):
            return .just(.initalPlan(planList))
        case let .reloadMonth(month):
            return reloadMonthlyPlan(months: month)
        }
    }
    
    private func handleChildEvent(_ event: Action.ChildEvent) -> Observable<Mutation> {
        switch event {
        case let .scrollToDate(date):
            delegate?.scrollToDate(date: date)
            currentMonth = DateManager.startOfMonth(date)
        case let .selectedPlan(plan):
            handleSelectedPlan(with: plan)
        }
        
        return .empty()
    }
    
    // MARK: - 상태 반영
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateNextPlan(list):
            newState.planList.append(contentsOf: list)
        case let .updatePreviousPlan(list):
            newState.planList.append(contentsOf: list)
            newState.previousPlanList = list
        case let .initalPlan(list):
            print(#function, #line, "#0407 list count : \(list.count)" )
            newState.planList = list
        case let .updateSelectedDate(date):
            newState.selectedDate = date
        case .resetPlan:
            newState.planList = []
            newState.reset = ()
        }
        
        return newState
    }
}

extension ScheduleListReactor: ScheduleListCommands {

    // 기본 일정 설정하기
    func setInitalList(with list: [Date]) {
        setIntialDatelist(with: list)
        fetchMonthPlan(on: currentMonth ?? Date())
    }
    
    // 캘린더로부터 넘어온 일정에서 월단위로 필터링
    private func setIntialDatelist(with list: [Date]) {
        let startMonth = list.compactMap { DateManager.startOfMonth($0) }
        let distinctDates = Set(startMonth)
        initalDateList = Array(distinctDates)
    }
    
    // 페이지에 해당하는 일정 불러오기
    func fetchMonthPlan(on month: Date) {
        currentMonth = DateManager.startOfMonth(month)
        resetPlanList()
        guard let currentMonth else { return }
        action.onNext(.parentCommand(.loadMonthlyPlan(currentMonth)))
    }
    
    // 페이지에 해당하는 일정 불러오기
    func loadMonthlyPlan(on month: Date) {
        guard let startMonth = DateManager.startOfMonth(month),
              let fetchType = getLoadMonthType(with: startMonth),
              isNeededLoadPlan(with: startMonth, type: fetchType) else { return }
        
        currentMonth = startMonth
        action.onNext(.parentCommand(.loadMorePlan(on: startMonth,
                                                   type: fetchType)))
    }
    
    private func getLoadMonthType(with month: Date) -> ScheduleFetchType? {
        guard let currentMonth else { return nil }
        return month > currentMonth ? .next : .previous
    }
    
    private func isNeededLoadPlan(with month: Date, type: ScheduleFetchType) -> Bool {
        switch type {
        case .next:
            return loadedDateList.contains { $0 >= month } == false
        case .previous:
            return loadedDateList.contains { $0 <= month } == false
        }
    }
    
    // 캘린더에서 선택된 날짜 스케줄리스트와 동기화
    func selectedDate(on date: Date) {
        action.onNext(.parentCommand(.selectedDate(date)))
    }
    
    // 만료된 일정이 있는 경우 업데이트
    func planUpdateWhenMidnight() {
        var reloadMonth: Set<Date> = .init()
        let filterPlan = currentState.planList.filter { $0.type == .plan }
        let planDate = filterPlan.compactMap { $0.date }
        let expriedPlan = planDate.filter { DateManager.isPastDay(on: $0) }
        expriedPlan.forEach {
            guard let month = DateManager.startOfMonth($0) else { return }
            reloadMonth.insert(month)
        }
        action.onNext(.parentCommand(.reloadMonth(Array(reloadMonth))))
    }
    
    // 초기셋업
    func resetPlanList() {
        isLoading = false
        loadState = .none
        lastLoadMonth = nil
        monthDateList = initalDateList
        loadedDateList.removeAll()
        action.onNext(.parentCommand(.resetPlan))
    }
}

// MARK: - 데이터 요청
extension ScheduleListReactor {
    
    /// 일정 데이터 요청
    private func fetchMonthDate(month: Date) -> Observable<[MonthlyPlan]> {
        guard let monthString = DateManager.toString(date: month, format: .month) else {
            return .just([])
        }
        
        updateRemainingMonth(month: month)
        
        return fetchMonthlyPlanUseCase.execute(month: monthString)
            .asObservable()
            .catchAndReturn([])
            .do(onNext: { [weak self] planList in
                self?.updateLoadedMonth(month: month,
                                        planList: planList)
            })
    }
    
    // MARK: - 기본 표시할 일정데이터 불러오기
    
    /// 요청리스트에서 현재 달, 이전 달, 다음 달 데이터를 요청
    /// 받아온 일정의 갯수가 5개 이하라면 재요청
    
    private func fetchInitialPlans(with month: Date) -> Observable<Mutation> {
        let fetchPlan = fetchTimelinePlans(with: month)
        return requestWithLoading(task: fetchPlan)
    }
    
    private func fetchTimelinePlans(with month: Date,
                                    accumulated: [MonthlyPlan] = []) -> Observable<Mutation> {
        
        let fetchList = findTimelineList(from: month)
        if fetchList.isEmpty {
            return .just(.initalPlan(accumulated))
        } else {
            let fetchMonths = mergeOrWrapMonthlyPlans(with: fetchList,
                                                         accumulated: accumulated)
                .flatMap({ [weak self] planList -> Observable<Mutation> in
                    guard let self,
                          planList.count < 5 else { return .just(.initalPlan(planList)) }
                    return fetchTimelinePlans(with: month,
                                              accumulated: planList)
                })
            
            return fetchMonths
        }
    }
    
    private func mergeOrWrapMonthlyPlans(with loadList: [Date],
                                            accumulated: [MonthlyPlan] = []) -> Observable<[MonthlyPlan]> {
        guard let zippedPlans = zipMonthlyPlansIfNeeded(with: loadList) else { return .just(accumulated) }
        return zippedPlans.map { $0 + accumulated }
    }
    
    // MARK: - 스크롤시 데이터 불러오기
    
    /// 스크롤 방향에 따라서 추가 일정 요청
    private func moreFetchMonthlyPlan(on date: Date,
                                      type: ScheduleFetchType) -> Observable<Mutation> {
        guard isLoading == false else { return .empty() }
        isLoading = true
        
        let fetchPlanObserver = moreFetchMonthlyPlanIfNeeded(on: date,
                                                             type: type)
            .catchAndReturn([])
            .flatMap { planList -> Observable<Mutation> in
                switch type {
                case .next:
                    return .just(.updateNextPlan(planList))
                case .previous:
                    return .just(.updatePreviousPlan(planList))
                }
            }

        return requestWithLoading(task: fetchPlanObserver)
            .do(onDispose: { [weak self] in
                self?.isLoading = false
            })
    }
    
    /// month에 해당하는 일정을 요청
    /// 응답받은 일정의 갯수가 5개 이하인 경우 추가요청
    private func moreFetchMonthlyPlanIfNeeded(on date: Date,
                                              with accumulated: [MonthlyPlan] = [],
                                              type: ScheduleFetchType) -> Observable<[MonthlyPlan]> {
        guard let fetchDate = getMoreFetchDate(on: date,
                                               type: type) else { return .just(accumulated) }
        
        return fetchMonthDate(month: fetchDate)
            .map({ $0 + accumulated })
            .flatMap { [weak self] plans -> Observable<[MonthlyPlan]> in
                guard let self,
                      plans.count < 5 else { return .just(plans)}
                
                return moreFetchMonthlyPlanIfNeeded(on: fetchDate,
                                                    with: plans,
                                                    type: type)
            }
    }

    // MARK: - 만료된 일정이 있는 경우 새로고침
    /// 새로고침이 필요한 달의 일정 다시 받아오기
    private func reloadMonthlyPlan(months: [Date]) -> Observable<Mutation> {
        
        guard let zippedPlans = zipMonthlyPlansIfNeeded(with: months) else {
            return .empty()
        }
        
        return zippedPlans
            .flatMap { [weak self] reloadPlans -> Observable<Mutation> in
                guard let self else { return .empty() }
                let updatePlanList = replaceMonthlyPlan(month: months,
                                                        newPlan: reloadPlans)
                return .just(.initalPlan(updatePlanList))
            }
    }

    private func replaceMonthlyPlan(month: [Date], newPlan: [MonthlyPlan]) -> [MonthlyPlan] {
        var planList = currentState.planList
        
        month.forEach { updateMonth in
            planList.removeAll { plan in
                guard let date = plan.date else { return false }
                return DateManager.isSameMonth(date, updateMonth)
            }
        }
        
        planList.append(contentsOf: newPlan)
        return planList
    }
}

// MARK: - 일정 선택
extension ScheduleListReactor {
    
    /// 일정 선택 시 타입과 날짜를 확인 후 맞는 타입으로 delegate에게 전달
    private func handleSelectedPlan(with plan: MonthlyPlan) {
        guard let id = plan.id else { return }
        if plan.type == .plan {
            handlePlanDate(id: id,
                          with: plan)
        } else {
            delegate?.selectedPlan(id: id,
                                   type: .review)
        }
    }
    
    private func handlePlanDate(id: Int,
                               with plan: MonthlyPlan) {
        guard let date = plan.date else { return }
        
        if DateManager.isPastDay(on: date) == false {
            delegate?.selectedPlan(id: id,
                                   type: .plan)
        } else {
            parent?.catchError(DateTransitionError.midnightReset,
                               index: 1)
        }
    }
}

// MARK: - 일정, 모임, 리뷰 변경 알림 수신
extension ScheduleListReactor {
    
    // MARK: - 페이로드 수신
    func editMeet(payload: MeetPayload) {
        var planList = currentState.planList
        
        switch payload {
        case let .updated(meet):
            guard let meetSummary = meet.meetSummary else { return }
            updateMeet(&planList, meet: meetSummary)
        default: break
        }
        action.onNext(.parentCommand(.editPlanList(planList)))
    }
    
    func editPlan(payload: PlanPayload) {
        var planList = currentState.planList
        
        switch payload {
        case let .created(plan):
            self.updatePlan(&planList, plan: plan)
        case let .updated(plan):
            self.deletePlan(&planList, planId: plan.id)
            self.updatePlan(&planList, plan: plan)
        case let .deleted(id):
            self.deletePlan(&planList, planId: id)
        }
        action.onNext(.parentCommand(.editPlanList(planList)))
    }
    
    func editReview(payload: ReviewPayload) {
        var planList = currentState.planList
        
        switch payload {
        case let .deleted(id):
            deletePlan(&planList, planId: id)
        default:
            break
        }
        
        action.onNext(.parentCommand(.editPlanList(planList)))
    }
    
    // MARK: - 모임 변경
    /// 미팅의 이름, 사진이 변경된 경우 일치하는 일정의 미팅 정보를 변경
    private func updateMeet(_ planList: inout [MonthlyPlan], meet: MeetSummary) {
        planList.indices.forEach {
            guard planList[$0].meet?.id == meet.id else { return }
            planList[$0].meet = meet
        }
    }
    
    // MARK: - 일정 변경
    /// 일정에 변경사항이 있을 경우 일치하는 일정의 값을 변경
    private func updatePlan(_ planList: inout [MonthlyPlan], plan: Plan) {
        guard let newDate = plan.date else { return }
        handleUpdate(&planList, plan: plan)
        delegate?.updateDateList(type: .add(newDate))
    }
    
    private func handleUpdate(_ planList: inout [MonthlyPlan], plan: Plan) {
        guard let newDate = plan.date,
              let monthDate = DateManager.startOfMonth(newDate) else { return }
        
        if planList.isEmpty ||
            isLoadedDate(on: monthDate) ||
            isBetweenLoadedDate(on: monthDate) ||
            isBetweenPreviousDate(on: monthDate) ||
            isBetweenNextDate(on: monthDate) {
            planList.append(.init(plan: plan))
            updateLoadedList(newDate: monthDate)
        } else {
            updateMonthList(newDate: monthDate)
        }
    }
    
    /// 불러온 날짜에 속해있다면 추가
    private func isLoadedDate(on newDate: Date) -> Bool {
        return loadedDateList.contains(where: { DateManager.isSameMonth($0, newDate) })
    }
    
    /// 불러온 날짜 중 가장 작은 것, 가장 큰 것 사이에 있다면 추가
    private func isBetweenLoadedDate(on newDate: Date) -> Bool {
        guard let minLoadedDate = loadedDateList.min(),
              let maxLoadedDate = loadedDateList.max() else { return true }
        return DateManager.isBetween(targetDate: newDate,
                                     startDate: minLoadedDate,
                                     endDate: maxLoadedDate)
    }
    
    /// 불러온 날짜 중 가장 작은 것과 그 이전 날짜 사이라면 추가 (그 이전 날짜가 없어도 추가)
    private func isBetweenPreviousDate(on newDate: Date) -> Bool {
        guard let loadedDate = loadedDateList.min(),
              let activeMonth = findLargestPreviousMonth(from: loadedDate) else { return true }
        return DateManager.isBetween(targetDate: newDate,
                                     startDate: loadedDate,
                                     endDate: activeMonth)
    }
    
    /// 불러온 날짜 중 가장 큰 것과 그 이후 날짜 사이라면 추가 (그 이후 날짜가 없어도 추가)
    private func isBetweenNextDate(on newDate: Date) -> Bool {
        guard let loadedDate = loadedDateList.max(),
              let activeMonth = findSmallestNextMonth(from: loadedDate) else { return true }
        return DateManager.isBetween(targetDate: newDate,
                                     startDate: loadedDate,
                                     endDate: activeMonth)
    }
    
    /// 불러온 달 리스트에 추가
    private func updateLoadedList(newDate: Date) {
        guard loadedDateList.contains(where: { $0 == newDate }) == false else { return }
        initalDateList.append(newDate)
        loadedDateList.append(newDate)
    }
    
    /// 위의 모든 조건에 적합하지 않다면 불러올 달 리스트에 추가
    private func updateMonthList(newDate: Date) {
        monthDateList.append(newDate)
        initalDateList.append(newDate)
        updateLoadState()
    }
    
    // MARK: - 일정 삭제
    /// 일정 삭제
    private func deletePlan(_ planList: inout [MonthlyPlan], planId: Int?) {
        guard let deleteIndex = findPlanIndex(id: planId),
              let deleteDate = planList[deleteIndex].date else { return }
        planList.remove(at: deleteIndex)
        guard isContainsDate(with: planList, date: deleteDate) == false else { return }
        loadedDateList.removeAll { return DateManager.isSameMonth($0, deleteDate) }
        delegate?.updateDateList(type: .delete(deleteDate))
    }
}

// MARK: - 요청 일자 및 상태 업데이트
extension ScheduleListReactor {
    /// monthList에서 불러온 날짜 제거 및 저장
    /// 데이터가 있는 경우엔 불러온 리스트 및 마지막 불러온 달로 저장
    /// 데이터가 없는 경우엔 삭제 처리
    private func updateRemainingMonth(month: Date) {
        monthDateList.removeAll { $0 == month }
        updateLoadState()
    }
    
    /// 요청 가능한 상태 업데이트
    private func updateLoadState() {
        guard let currentMonth else { return }
        let isNext = monthDateList.contains { $0 > currentMonth }
        let isPrevious = monthDateList.contains { $0 < currentMonth }
        
        loadState =
        switch (isNext, isPrevious) {
        case (true, true): .all
        case (true, false): .next
        case (false, true): .previous
        case (false, false): .none
        }
    }
    
    private func updateLoadedMonth(month: Date,
                                   planList: [MonthlyPlan]) {
        if planList.isEmpty == false {
            loadedDateList.append(month)
            lastLoadMonth = month
            delegate?.updateDateList(type: .update(at: month,
                                                   with: planList.compactMap({ $0.date })))
        } else {
            initalDateList.removeAll { $0 == month }
            delegate?.deleteMonth(month: month)
        }
    }
}

// MARK: - Helper
extension ScheduleListReactor {
    
    /// type에 따라서 요청할 month
    // 스케줄리스트에서 추가요청 할 땐 monthDateList에 값이 없으나 캘린더에서 추가요청 할 땐 monthDateList에 값이 있을 수 있음
    private func getMoreFetchDate(on date: Date,
                                  type: ScheduleFetchType) -> Date? {
        if monthDateList.contains(where: { $0 == date }) {
            return date
        } else {
            return findNextFetchDate(on: date, type: type)
        }
    }
    
    /// monthList에서 마지막으로 불러온 날짜와 가까운 날짜
    /// - Parameter type: 가까운 기준 (이전 or 다음)
    private func findNextFetchDate(on date: Date,
                                   type: ScheduleFetchType) -> Date? {
        switch type {
        case .next:
            return findSmallestNextMonth(from: date)
        case .previous:
            return findLargestPreviousMonth(from: date)
        }
    }
    
    /// monthList에서 date로부터 앞뒤로 가까운 날짜 리스트
    /// - Parameter date: 타켓 날짜
    /// - Returns: 불러올 달 리스트
    private func findTimelineList(from date: Date) -> [Date] {
        return [findLargestPreviousMonth(from: date),
                findSameMonth(from: date),
                findSmallestNextMonth(from: date)].compactMap { $0 }
    }

    private func findSameMonth(from date: Date) -> Date? {
        return monthDateList.filter { $0 == date }.first
    }
    
    /// monthList에서 date로부터 뒤로 가까운 날짜
    private func findLargestPreviousMonth(from date: Date) -> Date? {
        return monthDateList.filter { $0 < date }.max()
    }
    
    /// monthList에서 date로부터 앞으로 가까운 날짜
    private func findSmallestNextMonth(from date: Date) -> Date? {
        return monthDateList.filter { $0 > date }.min()
    }
    
    /// 불러올 monthList의 갯수에 따라서 적절한 Observable 형태로 조정
    private func zipMonthlyPlansIfNeeded(with monthList: [Date]) -> Observable<[MonthlyPlan]>? {
        let observables = monthList.compactMap { [weak self] in
            self?.fetchMonthDate(month: $0)
        }
        switch observables.count {
        case 1:
            return observables.first
        case 2...:
            return Observable.zip(observables)
                .map { $0.flatMap { $0 } }
        default:
            return nil
        }
    }
    
    /// list에 date가 포함되어 있는지 확인
    private func isContainsDate(with list: [MonthlyPlan], date: Date) -> Bool {
        return list.contains {
            guard let planDate = $0.date else { return false }
            return DateManager.isSameDay(planDate, date)
        }
    }
    
    /// 현재 일정 리스트에서 id와 해당하는 일정 인덱스 찾기
    private func findPlanIndex(id: Int?) -> Int? {
        return currentState.planList.firstIndex { $0.id == id }
    }
}

extension ScheduleListReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
    var index: Int { 1 }
}

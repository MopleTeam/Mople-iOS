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
    func reloadDay(on date: Date)
    func updatePlanMonthList(with list: [Date])
    func loadMonthlyPlan(on month: DateComponents)
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
            case loadInitalPlan([Date])
            case editPlanList([MonthlyPlan])
            case reloadMonth(Date)
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
        case updateMonthlyPlan([MonthlyPlan])
        case updateSelectedDate(Date)
        case updateAddPlanList([MonthlyPlan])
        case editPlanList([MonthlyPlan])
        case resetPlan
    }
    
    struct State {
        @Pulse var planList: [MonthlyPlan] = []
        @Pulse var selectedDate: Date?
        @Pulse var addPlanList: [MonthlyPlan] = []
        @Pulse var reset: Void? 
    }
    
    var initialState: State = State()
    private let todayComponents = Date().toDateComponents()
    private let fetchMonthlyPlanUseCase: FetchMonthlyPlan
    private weak var delegate: SchduleListReactorDelegate?
    private var currentMonth = Date().toMonthComponents().toDate()
    private var initalDateList: [Date] = []
    private var monthDateList: [Date] = []
    private var loadedDateList: [Date] = []
    private var lastLoadMonth: Date?
    private var isLoading: Bool = false
    private(set) var loadState: LoadState = .none
    
    init(fetchMonthlyPlanUseCase: FetchMonthlyPlan,
         delegate: SchduleListReactorDelegate) {
        self.fetchMonthlyPlanUseCase = fetchMonthlyPlanUseCase
        self.delegate = delegate
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .parentCommand(action):
            switch action {
            case let .loadMonthlyPlan(month):
                return recursionFetchMonthlyListPlan(month: [month])
            case let .selectedDate(date):
                return .just(.updateSelectedDate(date))
            case .resetPlan:
                return .just(.resetPlan)
            case let .loadInitalPlan(dateList):
                return recursionFetchMonthlyListPlan(month: dateList)
            case let .editPlanList(planList):
                return .just(.editPlanList(planList))
            case let .reloadMonth(month):
                return reloadMonthlyPlan(month: month)
            }
            
        case let .childEvent(event):
            return handleChildEvent(event)
        case let .getMorePlan(type):
            return moreFetchMonthlyPlan(type: type)
        }
    }
    
    private func handleChildEvent(_ event: Action.ChildEvent) -> Observable<Mutation> {
        switch event {
        case let .scrollToDate(date):
            delegate?.scrollToDate(date: date)
        case let .selectedPlan(plan):
            handleSelectedPlan(with: plan)
        }
        
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateMonthlyPlan(list):
            newState.planList.append(contentsOf: list)
        case let .updateAddPlanList(list):
            newState.planList.append(contentsOf: list)
            newState.addPlanList = list
        case let .editPlanList(list):
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
    func updatePlanMonthList(with list: [Date]) {
        guard let currentMonth else { return }
        initalDateList = list
        resetPlanList()
        action.onNext(.parentCommand(.loadInitalPlan(findFetchDateList(from: currentMonth))))
    }
    
    func loadMonthlyPlan(on month: DateComponents) {
        guard let monthDate = month.toDate() else { return }
        currentMonth = monthDate
        action.onNext(.parentCommand(.loadInitalPlan(findFetchDateList(from: monthDate))))
    }
    
    func selectedDate(on date: Date) {
        action.onNext(.parentCommand(.selectedDate(date)))
    }
    
    func reloadDay(on date: Date) {
        let planDate = currentState.planList.compactMap { $0.date }
        guard planDate.contains(where: { DateManager.isSameDay($0, date) }) else { return }
        action.onNext(.parentCommand(.reloadMonth(date)))
    }
    
    func resetPlanList() {
        isLoading = false
        lastLoadMonth = nil
        monthDateList = initalDateList
        loadedDateList.removeAll()
        action.onNext(.parentCommand(.resetPlan))
    }
}

// MARK: - 데이터 요청
extension ScheduleListReactor {
    
    /// 서버에게 일정을 요청
    /// 받아온 일정의 수가 5개보다 적을 경우 재귀호출
    /// - Parameters:
    ///   - month: 요청할 달
    ///   - accumulated: 중첩 일정 리스트
    ///   - type: 일정을 추가로 받아올 날짜의 방향(과거 or 미래)
    private func recursionFetchMonthlyPlan(month: Date,
                                           accumulated: [MonthlyPlan] = [],
                                           type: ScheduleFetchType) -> Observable<[MonthlyPlan]> {
        
        guard let monthString = DateManager.toString(date: month, format: .month) else {
            return .just([])
        }
        
        return fetchMonthlyPlanUseCase.execute(month: monthString)
            .asObservable()
            .do(onNext: { [weak self] planList in
                self?.updateRemainingMonth(month: month,
                                           planList: planList)
            })
            .map({ $0 + accumulated })
            .flatMap { [weak self] plans -> Observable<[MonthlyPlan]> in
                guard let self else { return .just(plans)}
                return handleRecursionFetch(type: type,
                                            loadedList: plans)
            }
    }
    
    /// 일정의 갯수가 5개 이상이라면 그대로 return
    /// 이하라면 재귀호출
    private func handleRecursionFetch(type: ScheduleFetchType,
                                      loadedList:[MonthlyPlan]) -> Observable<[MonthlyPlan]> {
        if loadedList.count < 5,
           let fetchDate = findFetchDate(type: type) {
            return recursionFetchMonthlyPlan(month: fetchDate,
                                                 accumulated: loadedList,
                                                 type: type)
        } else {
            return .just(loadedList)
        }
    }
    
    /// 새로고침이 필요한 달의 일정 다시 받아오기
    private func reloadMonthlyPlan(month: Date) -> Observable<Mutation> {
        guard isLoading == false,
              let monthString = DateManager.toString(date: month, format: .month) else {
            return .empty()
        }
        isLoading = true
        
        let reloadMonth = fetchMonthlyPlanUseCase.execute(month: monthString)
            .asObservable()
            .flatMap { [weak self] monthPlan -> Observable<Mutation> in
                guard let self else { return .empty() }
                let newPlanList = removeMonthlyPlan(month: month,
                                                    newPlan: monthPlan)
                
                return .just(.editPlanList(newPlanList))
            }
        
        return requestWithLoading(task: reloadMonth,
                                  completionHandler: { [weak self] in
            self?.isLoading = false
        }, errorHandler: { [weak self] in
            self?.isLoading = false
        })
    }
    
    private func removeMonthlyPlan(month: Date, newPlan: [MonthlyPlan]) -> [MonthlyPlan] {
        var planList = currentState.planList
        planList.removeAll {
            guard let date = $0.date else { return false }
            return DateManager.isSameMonth(date, month)
        }
        
        planList.append(contentsOf: newPlan)
        return planList
    }
    
    /// 요청 타입에 따라서 추가 일정 요청
    private func moreFetchMonthlyPlan(type: ScheduleFetchType) -> Observable<Mutation> {
        guard isLoading == false,
              let fetchDate = findFetchDate(type: type) else { return .empty() }
        isLoading = true
        
        let fetchPlanObserver = recursionFetchMonthlyPlan(month: fetchDate,
                                                          type: type)
            .flatMap { planList -> Observable<Mutation> in
                switch type {
                case .next:
                    return .just(.updateMonthlyPlan(planList))
                case .previous:
                    return .just(.updateAddPlanList(planList))
                }
            }

        return requestWithLoading(task: fetchPlanObserver,
                                  completionHandler: { [weak self] in
            self?.isLoading = false
        }, errorHandler: { [weak self] in
            self?.isLoading = false
        })
    }

    /// 여러 달의 일정을 요청
    private func recursionFetchMonthlyListPlan(month: [Date]) -> Observable<Mutation> {
        guard isLoading == false,
              month.isEmpty == false,
              let currentMonth else { return .empty() }
        
        isLoading = true
        
        let fetchPlanObserver = month.map {
            let fetchType: ScheduleFetchType = currentMonth > $0 ? .previous : .next
            return recursionFetchMonthlyPlan(month: $0,
                                             type: fetchType)
        }
        
        let fetchPlanZipObserver = Observable.zip(fetchPlanObserver)
            .map { $0.flatMap { $0 } }
            .map { Mutation.updateMonthlyPlan($0) }
        
        return requestWithLoading(task: fetchPlanZipObserver,
                                  completionHandler: { [weak self] in
            self?.isLoading = false
        }, errorHandler: { [weak self] in
            self?.isLoading = false
        })
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
            parent?.catchError(PlanDetailError.expiredPlan(date), index: 1)
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
            break
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
    
    // MARK: - 일정 변경
    
    /// 미팅의 이름, 사진이 변경된 경우 일치하는 일정의 미팅 정보를 변경
    private func updateMeet(_ planList: inout [MonthlyPlan], meet: MeetSummary) {
        planList.indices.forEach {
            guard planList[$0].meet?.id == meet.id else { return }
            planList[$0].meet = meet
        }
    }
    
    /// 일정에 변경사항이 있을 경우 일치하는 일정의 값을 변경
    private func updatePlan(_ planList: inout [MonthlyPlan], plan: Plan) {
        guard let newDate = plan.date else { return }
        handleUpdate(&planList, plan: plan)
        delegate?.updateDateList(type: .add(DateManager.startOfDay(newDate)))
    }
    
    private func handleUpdate(_ planList: inout [MonthlyPlan], plan: Plan) {
        guard let newDate = plan.date,
              let monthDate = newDate.toMonthComponents().toDate() else { return }
        
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
    
    // MARK: - 삭제
    /// 일정 삭제
    private func deletePlan(_ planList: inout [MonthlyPlan], planId: Int?) {
        guard let deleteIndex = findPlanIndex(id: planId),
              let deleteDate = planList[deleteIndex].date else { return }
        planList.remove(at: deleteIndex)
        
        // 삭제된 날짜의 달에 잔여 데이터가 없다면 loadedDateList에서 삭제
        guard planList.contains(where: { guard let date = $0.date else { return false }
            return DateManager.isSameDay(date, deleteDate) }) == false else { return }
        
        loadedDateList.removeAll { return DateManager.isSameMonth($0, deleteDate) }
        delegate?.updateDateList(type: .delete(DateManager.startOfDay(deleteDate)))
    }
    
    /// 현재 일정 리스트에서 삭제할 리뷰의 인덱스 얻기
    private func findPlanIndex(id: Int?) -> Int? {
        return currentState.planList.firstIndex { $0.id == id }
    }
}

// MARK: - Helper
extension ScheduleListReactor {
    
    /// monthList에서 date로부터 앞뒤로 가까운 날짜 리스트
    /// - Parameter date: 타켓 날짜
    /// - Returns: 불러올 달 리스트
    private func findFetchDateList(from date: Date) -> [Date] {
        return [findLargestPreviousMonth(from: date),
                findSmallestNextMonth(from: date)].compactMap { $0 }
    }
    
    /// monthList에서 마지막으로 불러온 날짜와 가까운 날짜
    /// - Parameter type: 가까운 기준 (이전 or 다음)
    private func findFetchDate(type: ScheduleFetchType) -> Date? {
        guard let lastLoadMonth else { return nil }
        switch type {
        case .next:
            return findSmallestNextMonth(from: lastLoadMonth)
        case .previous:
            return findLargestPreviousMonth(from: lastLoadMonth)
        }
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
        return monthDateList.filter { $0 >= date }.min()
    }
    
    /// monthList에서 불러온 날짜 제거 및 저장
    /// 데이터가 있는 경우엔 불러온 리스트 및 마지막 불러온 달로 저장
    /// 데이터가 없는 경우엔 삭제 처리
    private func updateRemainingMonth(month: Date,
                                      planList: [MonthlyPlan]) {
        monthDateList.removeAll { $0 == month }
        updateLoadState()
        
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
    
    /// 요청 가능한 상태 업데이트
    private func updateLoadState() {
        guard let currentDate = currentMonth else { return }
        let isNext = monthDateList.contains { $0 > currentDate }
        let isPrevious = monthDateList.contains { $0 < currentDate }
        
        loadState =
        switch (isNext, isPrevious) {
        case (true, true): .all
        case (true, false): .next
        case (false, true): .previous
        case (false, false): .none
        }
    }
}

extension ScheduleListReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
    var index: Int { 1 }
}

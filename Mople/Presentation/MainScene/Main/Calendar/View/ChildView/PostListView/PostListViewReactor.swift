//
//  ScheduleReactor.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import ReactorKit

protocol PostListCommands: AnyObject {
    func resetPostList()
    func updateWhenMidnight()
    func setInitialList(with list: [Date])
    func fetchMonthPlan(on month: Date)
    func loadMonthlyPost(on month: Date)
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

final class PostListViewReactor: Reactor {
    
    enum Action {
        enum ParentCommand {
            case resetPost
            case selectedDate(Date)
            case fecthPost(Date)
            case fetchMorePost(on: Date, type: ScheduleFetchType)
            case editPostList([MonthlyPost])
            case reloadMonth([Date])
        }
        
        enum ChildEvent {
            case scrollToDate(Date)
            case selectedPost(MonthlyPost)
        }
        
        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case getMorePost(ScheduleFetchType)
    }
    
    enum Mutation {
        case updateInitialPost([MonthlyPost])
        case updateNextPost([MonthlyPost])
        case updatePreviousPost([MonthlyPost])
        case updateSelectedDate(Date)
        case resetPost
    }
    
    struct State {
        @Pulse var postList: [MonthlyPost] = []
        @Pulse var selectedDate: Date?
        @Pulse var previousPostList: [MonthlyPost] = []
        @Pulse var reset: Void?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var currentMonth: Date?
    private var initialDateList: [Date] = []
    private var monthDateList: [Date] = []
    private var loadedDateList: [Date] = []
    private var lastLoadMonth: Date?
    private var isLoading: Bool = false
    private(set) var loadState: LoadState = .none
    
    // MARK: - UseCase
    private let fetchMonthlyPostUseCase: FetchMonthlyPost
    
    // MARK: - Delegate
    private weak var delegate: PostListReactorDelegate?
    
    // MARK: - LifeCylce
    init(fetchMonthlyPostUseCase: FetchMonthlyPost,
         delegate: PostListReactorDelegate) {
        self.fetchMonthlyPostUseCase = fetchMonthlyPostUseCase
        self.delegate = delegate
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .parentCommand(command):
            return handleParentCommand(command)
        case let .childEvent(event):
            return handleChildEvent(event)
        case let .getMorePost(type):
            guard let lastLoadMonth else { return .empty() }
            return moreFetchPost(on: lastLoadMonth,
                                        type: type)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateNextPost(list):
            newState.postList.append(contentsOf: list)
        case let .updatePreviousPost(list):
            newState.postList.append(contentsOf: list)
            newState.previousPostList = list
        case let .updateInitialPost(list):
            newState.postList = list
        case let .updateSelectedDate(date):
            newState.selectedDate = date
        case .resetPost:
            newState.postList = []
            newState.reset = ()
        }
        
        return newState
    }
}

// MARK: - Action Handling
extension PostListViewReactor {
    private func handleParentCommand(_ command: Action.ParentCommand) -> Observable<Mutation> {
        switch command {
        case let .fecthPost(month):
            return fetchInitialPost(with: month)
        case let .fetchMorePost(month,
                               fetchType):
            return moreFetchPost(on: month,
                                        type: fetchType)
        case let .selectedDate(date):
            return .just(.updateSelectedDate(date))
        case .resetPost:
            return .just(.resetPost)
        case let .editPostList(planList):
            return .just(.updateInitialPost(planList))
        case let .reloadMonth(month):
            return reloadPost(months: month)
        }
    }
    
    private func handleChildEvent(_ event: Action.ChildEvent) -> Observable<Mutation> {
        switch event {
        case let .scrollToDate(date):
            delegate?.scrollToDate(date: date)
            currentMonth = DateManager.startOfMonth(date)
        case let .selectedPost(plan):
            handleSelectedPost(with: plan)
        }
        
        return .empty()
    }
}

// MARK: - Data Request
extension PostListViewReactor {
    
    /// 일정 데이터 요청
    private func fetchPost(month: Date) -> Observable<[MonthlyPost]> {
        guard let monthString = DateManager.toString(date: month, format: .month) else {
            return .just([])
        }
        
        updateRemainingMonth(month: month)
        
        return fetchMonthlyPostUseCase.execute(month: monthString)
            .catchAndReturn([])
            .do(onNext: { [weak self] planList in
                self?.updateLoadedMonth(month: month,
                                        planList: planList)
            })
    }
    
    /// fetch monthlist zip
    private func fetchPost(with monthList: [Date]) -> Observable<[MonthlyPost]> {
        guard monthList.isEmpty == false else { return .just([])}
        let observables = monthList.compactMap { [weak self] in
            self?.fetchPost(month: $0)
        }
        return Observable.zip(observables)
            .map { $0.flatMap { $0 } }
    }
    
    // MARK: - 기본 표시할 일정데이터 불러오기
    
    /// 요청리스트에서 현재 달, 이전 달, 다음 달 데이터를 요청
    /// 받아온 일정의 갯수가 5개 이하라면 재요청
    
    private func fetchInitialPost(with month: Date) -> Observable<Mutation> {
        let fetchPlan = fetchTimelinePost(with: month)
        return requestWithLoading(task: fetchPlan)
    }
    
    private func fetchTimelinePost(with month: Date,
                                    accumulated: [MonthlyPost] = []) -> Observable<Mutation> {
        
        let fetchList = findTimelineList(from: month)
        guard fetchList.isEmpty == false else { return .just(.updateInitialPost(accumulated))}
        
        return fetchPost(with: fetchList)
            .map { $0 + accumulated }
            .flatMap({ [weak self] postList -> Observable<Mutation> in
                guard let self else { return .empty() }
                
                if postList.count >= 5 {
                    return .just(.updateInitialPost(postList))
                } else {
                    return fetchTimelinePost(with: month,
                                              accumulated: postList)
                }
            })
    }
    
    // MARK: - 스크롤시 데이터 불러오기
    
    /// 스크롤 방향에 따라서 추가 일정 요청
    private func moreFetchPost(on date: Date,
                                      type: ScheduleFetchType) -> Observable<Mutation> {
        guard isLoading == false else { return .empty() }
        isLoading = true
        
        let fetchPostObserver = moreFetchPostIfNeeded(on: date,
                                                             type: type)
            .catchAndReturn([])
            .flatMap { postList -> Observable<Mutation> in
                switch type {
                case .next:
                    return .just(.updateNextPost(postList))
                case .previous:
                    return .just(.updatePreviousPost(postList))
                }
            }

        return requestWithLoading(task: fetchPostObserver)
            .do(onDispose: { [weak self] in
                self?.isLoading = false
            })
    }
    
    /// month에 해당하는 일정을 요청
    /// 응답받은 일정의 갯수가 5개 이하인 경우 추가요청
    private func moreFetchPostIfNeeded(on date: Date,
                                              with accumulated: [MonthlyPost] = [],
                                              type: ScheduleFetchType) -> Observable<[MonthlyPost]> {
        guard let fetchDate = getMoreFetchDate(on: date,
                                               type: type) else { return .just(accumulated) }
        
        return fetchPost(month: fetchDate)
            .map({ $0 + accumulated })
            .flatMap { [weak self] plans -> Observable<[MonthlyPost]> in
                guard let self,
                      plans.count < 5 else { return .just(plans)}
                
                return moreFetchPostIfNeeded(on: fetchDate,
                                                    with: plans,
                                                    type: type)
            }
    }

    // MARK: - 만료된 일정이 있는 경우 새로고침
    /// 새로고침이 필요한 달의 일정 다시 받아오기
    private func reloadPost(months: [Date]) -> Observable<Mutation> {
        guard months.isEmpty == false else { return .empty() }
        
        return fetchPost(with: months)
            .flatMap { [weak self] reloadPlans -> Observable<Mutation> in
                guard let self else { return .empty() }
                let updatePlanList = replacePost(month: months,
                                                        newPlan: reloadPlans)
                return .just(.updateInitialPost(updatePlanList))
            }
    }

    private func replacePost(month: [Date], newPlan: [MonthlyPost]) -> [MonthlyPost] {
        var planList = currentState.postList
        
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

// MARK: - Selected Plan
extension PostListViewReactor {
    
    /// 일정 선택 시 타입과 날짜를 확인 후 맞는 타입으로 delegate에게 전달
    private func handleSelectedPost(with post: MonthlyPost) {
        guard let id = post.id else { return }
        if post.type == .plan {
            handlePostDate(id: id,
                          with: post)
        } else {
            delegate?.selectedPost(id: id,
                                   type: .review)
        }
    }
    
    private func handlePostDate(id: Int,
                               with plan: MonthlyPost) {
        guard let date = plan.date else { return }
        
        if DateManager.isPastDay(on: date) == false {
            delegate?.selectedPost(id: id,
                                   type: .plan)
        } else {
            parent?.catchError(DateTransitionError.midnightReset,
                               index: 1)
        }
    }
}

// MARK: - Notify
extension PostListViewReactor {
    
    // MARK: - 페이로드 수신
    func editMeet(payload: MeetPayload) {
        var planList = currentState.postList
        
        switch payload {
        case let .updated(meet):
            guard let meetSummary = meet.meetSummary else { return }
            updateMeet(&planList, meet: meetSummary)
        default: break
        }
        action.onNext(.parentCommand(.editPostList(planList)))
    }
    
    func editPlan(payload: PlanPayload) {
        var planList = currentState.postList
        
        switch payload {
        case let .created(plan):
            self.updatePlan(&planList, plan: plan)
        case let .updated(plan):
            self.deletePlan(&planList, planId: plan.id)
            self.updatePlan(&planList, plan: plan)
        case let .deleted(id):
            self.deletePlan(&planList, planId: id)
        }
        action.onNext(.parentCommand(.editPostList(planList)))
    }
    
    func editReview(payload: ReviewPayload) {
        var planList = currentState.postList
        
        switch payload {
        case let .deleted(id):
            deletePlan(&planList, planId: id)
        default:
            break
        }
        
        action.onNext(.parentCommand(.editPostList(planList)))
    }
    
    // MARK: - 모임 변경
    /// 미팅의 이름, 사진이 변경된 경우 일치하는 일정의 미팅 정보를 변경
    private func updateMeet(_ planList: inout [MonthlyPost], meet: MeetSummary) {
        planList.indices.forEach {
            guard planList[$0].meet?.id == meet.id else { return }
            planList[$0].meet = meet
        }
    }
    
    // MARK: - 일정 변경
    /// 일정에 변경사항이 있을 경우 일치하는 일정의 값을 변경
    private func updatePlan(_ planList: inout [MonthlyPost], plan: Plan) {
        guard let newDate = plan.date else { return }
        handleUpdate(&planList, plan: plan)
        delegate?.updateDateList(type: .add(newDate))
    }
    
    private func handleUpdate(_ planList: inout [MonthlyPost], plan: Plan) {
        guard let newDate = plan.date,
              let monthDate = DateManager.startOfMonth(newDate),
              isActiveDate(on: monthDate) == false else {
            return
        }
        
        if planList.isEmpty || canAddPlan(planDate: newDate) {
            planList.append(.init(plan: plan))
            updateLoadedList(newDate: monthDate)
        } else {
            updateMonthList(newDate: monthDate)
        }
    }
    
    /// 불러올 날짜에 속해있는지 체크
    private func isActiveDate(on newDate: Date) -> Bool {
        return monthDateList.contains { DateManager.isSameMonth($0, newDate) }
    }
    
    private func canAddPlan(planDate: Date) -> Bool {
        guard let firstLoadedDate = loadedDateList.min(),
              let lastLoadedDate = loadedDateList.max() else { return false }
        
        return isLoadedDate(on: planDate) ||
        isBetweenLoadedDate(newDate: planDate,
                            firstLoaded: firstLoadedDate,
                            lastLoaded: lastLoadedDate) ||
        isBetweenPreviousDate(newDate: planDate,
                              firstLoaded: firstLoadedDate) ||
        isBetweenNextDate(newDate: planDate,
                          lastLoaded: lastLoadedDate)
    }
    
    /// 불러온 날짜에 속해있는지 체크
    private func isLoadedDate(on newDate: Date) -> Bool {
        return loadedDateList.contains(where: { DateManager.isSameMonth($0, newDate) })
    }
    
    /// 불러온 날짜 중 가장 작은 것, 가장 큰 것 사이에 있다면 추가
    private func isBetweenLoadedDate(newDate: Date,
                                     firstLoaded: Date,
                                     lastLoaded: Date) -> Bool {
        return DateManager.isWithinRange(target: newDate,
                                         from: firstLoaded,
                                         to: lastLoaded)
    }
    
    /// 불러온 날짜 중 가장 작은 것과 그 이전 날짜 사이라면 추가 (그 이전 날짜가 없어도 추가)
    /// -
    private func isBetweenPreviousDate(newDate: Date,
                                       firstLoaded: Date) -> Bool {
        guard newDate < firstLoaded else { return false }
        guard let inactiveMonth = findPreviousActiveMonth(from: firstLoaded) else { return true }
        return DateManager.isWithinRange(target: newDate,
                                         from: inactiveMonth,
                                         to: firstLoaded)
    }
    
    /// 불러온 날짜 중 가장 큰 것과 그 이후 날짜 사이라면 추가 (그 이후 날짜가 없어도 추가)
    private func isBetweenNextDate(newDate: Date,
                                   lastLoaded: Date) -> Bool {
        guard newDate > lastLoaded else { return false }
        guard let activeMonth = findNextActiveMonth(from: lastLoaded) else {
            return true
        }
        return DateManager.isWithinRange(target: newDate,
                                         from: lastLoaded,
                                         to: activeMonth)
    }
    
    /// 불러온 달 리스트에 추가
    private func updateLoadedList(newDate: Date) {
        guard loadedDateList.contains(where: { $0 == newDate }) == false else {
            return
        }
        
        initialDateList.append(newDate)
        loadedDateList.append(newDate)
    }
    
    /// 위의 모든 조건에 적합하지 않다면 불러올 달 리스트에 추가
    private func updateMonthList(newDate: Date) {
        monthDateList.append(newDate)
        initialDateList.append(newDate)
        updateLoadState()
    }
    
    // MARK: - 일정 삭제
    /// 일정 삭제
    private func deletePlan(_ planList: inout [MonthlyPost], planId: Int?) {
        guard let deleteIndex = findPlanIndex(id: planId),
              let deleteDate = planList[deleteIndex].date else { return }
        planList.remove(at: deleteIndex)
        deleteDateList(with: planList, deleteDate: deleteDate)
        deleteLoadedMonthList(with: planList, deleteDate: deleteDate)
    }
    
    private func deleteDateList(with postList: [MonthlyPost], deleteDate: Date) {
        guard !postList.contains(where: {
            guard let planDate = $0.date else { return true }
            return DateManager.isSameDay(planDate, deleteDate)
        }) else { return }
        delegate?.updateDateList(type: .delete(deleteDate))
    }
    
    private func deleteLoadedMonthList(with postList: [MonthlyPost], deleteDate: Date) {
        guard !postList.contains(where: {
            guard let planDate = $0.date else { return true }
            return DateManager.isSameMonth(planDate, deleteDate)
        }) else { return }
        loadedDateList.removeAll { return DateManager.isSameMonth($0, deleteDate) }
    }
}

// MARK: - Month List & Load State Update
extension PostListViewReactor {
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
                                   planList: [MonthlyPost]) {
        if planList.isEmpty == false {
            loadedDateList.append(month)
            lastLoadMonth = month
            delegate?.updateDateList(type: .update(at: month,
                                                   with: planList.compactMap({ $0.date })))
        } else {
            initialDateList.removeAll { $0 == month }
            delegate?.deleteMonth(month: month)
        }
    }
}

// MARK: - Commands
extension PostListViewReactor: PostListCommands {

    // 기본 일정 설정하기
    func setInitialList(with list: [Date]) {
        setIntialDatelist(with: list)
        fetchMonthPlan(on: currentMonth ?? Date())
    }
    
    // 캘린더로부터 넘어온 일정에서 월단위로 필터링
    private func setIntialDatelist(with list: [Date]) {
        let startMonth = list.compactMap { DateManager.startOfMonth($0) }
        let distinctDates = Set(startMonth)
        initialDateList = Array(distinctDates)
    }
    
    // 페이지에 해당하는 일정 불러오기
    func fetchMonthPlan(on month: Date) {
        currentMonth = DateManager.startOfMonth(month)
        resetPostList()
        guard let currentMonth else { return }
        action.onNext(.parentCommand(.fecthPost(currentMonth)))
    }
    
    // 페이지에 해당하는 일정 불러오기
    func loadMonthlyPost(on month: Date) {
        guard let startMonth = DateManager.startOfMonth(month),
              let fetchType = getLoadMonthType(with: startMonth),
              isContainLoadMonth(with: startMonth, type: fetchType) else { return }
        
        currentMonth = startMonth
        action.onNext(.parentCommand(.fetchMorePost(on: startMonth,
                                                   type: fetchType)))
    }
    
    private func getLoadMonthType(with month: Date) -> ScheduleFetchType? {
        guard let currentMonth else { return nil }
        return month > currentMonth ? .next : .previous
    }
    
    private func isContainLoadMonth(with month: Date, type: ScheduleFetchType) -> Bool {
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
    func updateWhenMidnight() {
        var reloadMonth: Set<Date> = .init()
        let filterPlan = currentState.postList.filter { $0.type == .plan }
        let planDate = filterPlan.compactMap { $0.date }
        let expriedPlan = planDate.filter { DateManager.isPastDay(on: $0) }
        expriedPlan.forEach {
            guard let month = DateManager.startOfMonth($0) else { return }
            reloadMonth.insert(month)
        }
        guard reloadMonth.isEmpty == false else { return }
        action.onNext(.parentCommand(.reloadMonth(Array(reloadMonth))))
    }
    
    // 초기셋업
    func resetPostList() {
        isLoading = false
        loadState = .none
        lastLoadMonth = nil
        monthDateList = initialDateList
        loadedDateList.removeAll()
        action.onNext(.parentCommand(.resetPost))
    }
}

// MARK: - Helper
extension PostListViewReactor {
    
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
            return findNextActiveMonth(from: date)
        case .previous:
            return findPreviousActiveMonth(from: date)
        }
    }
    
    /// monthList에서 date로부터 앞뒤로 가까운 날짜 리스트
    /// - Parameter date: 타켓 날짜
    /// - Returns: 불러올 달 리스트
    private func findTimelineList(from date: Date) -> [Date] {
        return [findPreviousActiveMonth(from: date),
                findSameActiveMonth(from: date),
                findNextActiveMonth(from: date)].compactMap { $0 }
    }
    
    private func findSameActiveMonth(from date: Date) -> Date? {
        return monthDateList.filter { DateManager.isSameMonth($0, date) }.first
    }
    
    /// monthList에서 date로부터 뒤로 가까운 날짜
    private func findPreviousActiveMonth(from date: Date) -> Date? {
        return monthDateList.filter { $0 < date }.max()
    }
    
    /// monthList에서 date로부터 앞으로 가까운 날짜
    private func findNextActiveMonth(from date: Date) -> Date? {
        return monthDateList.filter { $0 > date }.min()
    }
    
    /// 현재 일정 리스트에서 id와 해당하는 일정 인덱스 찾기
    private func findPlanIndex(id: Int?) -> Int? {
        return currentState.postList.firstIndex { $0.id == id }
    }
}

// MARK: - Loading & Error
extension PostListViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
    var index: Int { 1 }
}

//
//  CalendarViewController.swift
//  Group
//
//  Created by CatSlave on 9/13/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import ReactorKit
import FSCalendar

enum ScopeType {
    case week
    case month
}

final class CalendarViewController: BaseViewController, View {

    // MARK: - Reactor
    typealias Reactor = CalendarViewReactor
    var disposeBag = DisposeBag()

    // MARK: - Variables
    /// UI에 표시됨을 방지하기 위해 임시로 선택된 날짜
    private var preSelectedDate: Date?
    private let currentCalendar = DateManager.calendar
    private var events: [Date] = []
    private var isSystemDragging: Bool = false
    public var currentHeight: CGFloat?

    // MARK: - Observable
    private let scopeObserver: PublishRelay<ScopeType> = .init()
    private let pageObserver: PublishRelay<Date> = .init()
    private let monthObserver: PublishRelay<DateComponents> = .init()
    private let dateSelectionObserver: PublishRelay<Date> = .init()

    // MARK: - Gestrue
    private var panGesture: UIPanGestureRecognizer?
    private var gestureDirection: GestureDirection?
    private var startCalendarOffset: CGPoint?
    private var horizonGestureCount: Int = 0

    // MARK: - UI Components
    public let calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.scrollDirection = .horizontal
        calendar.adjustsBoundingRectWhenChangingMonths = true
        calendar.placeholderType = .none
        calendar.headerHeight = 0
        calendar.rowHeight = 60
        calendar.collectionViewLayout.sectionInsets = .init(top: 5, left: 24, bottom: 5, right: 24)
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }()

    private let weekContainerView = UIView()

    // MARK: - LifeCycle
    init(reactor: CalendarViewReactor) {
        super.init()
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setObservable()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setCalendar()
        setLayout()
    }
    
    private func setLayout() {
        view.layer.makeCornes(radius: 16, corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        view.backgroundColor = .defaultWhite
        view.addSubview(calendar)

        calendar.addSubview(weekContainerView)
        weekContainerView.addSubview(calendar.calendarWeekdayView)

        calendar.snp.makeConstraints { make in
            let calendarMaxHeight = calendar.weekdayHeight + (calendar.rowHeight * 6)
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(calendarMaxHeight)
        }

        weekContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(36)
        }

        calendar.calendarWeekdayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: CustomCalendarCell.reuseIdentifier)
        setCalendarAppearance()
    }

    private func setCalendarAppearance() {
        calendar.appearance.weekdayTextColor = .gray05
        calendar.appearance.titleSelectionColor = .appPrimary
        calendar.appearance.titleFont = FontStyle.Title3.semiBold
        calendar.appearance.weekdayFont = FontStyle.Body1.medium
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = .clear
    }

    // MARK: - Gesture Setup
    private func setObservable() {
        scopeObserver
            .distinctUntilChanged()
            .map { $0 == .month }
            .bind(to: self.view.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)
    }
    
    public func setPanGesture(gesture: UIPanGestureRecognizer) {
        self.panGesture = gesture
        
        panGesture!.rx.event
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { vc, gesture in
                vc.handleGesture(gesture)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Setup
extension CalendarViewController {
    func bind(reactor: CalendarViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
    }

    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        scopeObserver
            .distinctUntilChanged()
            .map { Reactor.Action.childEvent(.changedScope($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        pageObserver
            .filter({ [weak self] _ in
                return self?.calendar.scope == .month
            })
            .map { Reactor.Action.childEvent(.changedPage($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        monthObserver
            .map { Reactor.Action.childEvent(.changeMonth($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        dateSelectionObserver
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.childEvent(.selectedDate($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$dates)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, events in
                vc.updateEvents(with: events)
                vc.setDefaulsePreDate()
            })
            .disposed(by: disposeBag)
     
        reactor.pulse(\.$page)
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, date in
                vc.moveToPage(on: date)
            })
            .disposed(by: disposeBag)

        reactor.pulse(\.$scrollDate)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, date  in
                vc.selectedPresnetDate(on: date)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$changeScope)
            .observe(on: MainScheduler.instance)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, _ in
                vc.switchScope(type: .buttonTap)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$changeMonthScope)
            .observe(on: MainScheduler.instance)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, _ in
                vc.changeMonthScope(animated: false)
            })
            .disposed(by: disposeBag)
    }
}

extension CalendarViewController: FSCalendarDataSource {

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: CustomCalendarCell.reuseIdentifier, for: date, at: position) as! CustomCalendarCell
        cell.updateCell(isSelected: checkSelected(on: date),
                        isToday: DateManager.isSameDay(date, Date()))
        return cell
    }
}

// MARK: - Delegate
extension CalendarViewController: FSCalendarDelegate {

    func minimumDate(for calendar: FSCalendar) -> Date {
        return DateManager.getMinimumDate()
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        return DateManager.getMaximumDate()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        setPreSelectedDateWhenMonth()
        syncCurrentPage()
    }

    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return events.contains { DateManager.isSameDay($0, date) }
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        preSelectedDate = date
        switchScope(type: .dateTap)
        updateCell(on: date, isSelected: true)
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateCell(on: date, isSelected: false)
    }

    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        let maxHeight = calendar.rowHeight * 6
        let currentScope: ScopeType = calendar.scope == .month ? .month : .week
        currentHeight = calendar.scope == .month ? maxHeight : bounds.height
        self.scopeObserver.accept(currentScope)
    }
}

extension CalendarViewController: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {

        switch date {
        case _ where events.contains(where: { DateManager.isSameDay($0, date) }):
            return .gray01
        default :
            return .gray07
        }
    }
}

// MARK: - 스코프 업데이트
extension CalendarViewController {
    
    enum ScopeChangeType {
        case buttonTap
        case dateTap
    }
    
    /// 스코프에 맞춰서 캘린더 뷰 높이 조절
    private func updateHeight(_ height: CGFloat) {
        calendar.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }

    /// 스위치 방식에 따라서 처리
    /// 포커싱 할 date ScheduleTableViewController에게 알리기
    private func switchScope(type: ScopeChangeType) {
        handleSwitchType(type)
        scopeSync()
    }

    /// 버튼으로 탭하는 경우 : 날짜 선택, 스코프 전환, empty 이벤트인 경우 handle
    /// 날짜 탭으로 하는 경우 : 스코프 전환
    /// 제스처로 전환한 경우 : none
    private func handleSwitchType(_ type: ScopeChangeType) {
        switch type {
        case .buttonTap:
            setFoucsDate()
            changeScope()
            handleEmptyMonthEvent()
        case .dateTap:
            changeScope()
        }
    }

    /// scope에 맞춰서 표시할 데이터 동기화
    /// month : week에서 previous, current, next 날짜 클릭에 따라서 calenar가 맞는 날짜를 표시해줌
    private func scopeSync() {
        switch calendar.scope {
        case .month:
            sendCurrentPageToHeader()
        case .week:
            sendSelectedDateToTable()
        @unknown default:
            break
        }
    }

    private func syncCurrentPage() {
        guard isSystemDragging == false else { return }
        sendCurrentPageToHeader()
        sendCurrrentPageToTable()
    }
    
    // 확인
    /// 주간에서 월간으로 변경할 때 DatePicker, MainHeaderLabel 반영을 위해서 monthObserver에 값 보내기
    private func sendCurrentPageToHeader() {
        monthObserver.accept(calendar.currentPage.toDateComponents())
    }
    
    private func sendCurrrentPageToTable() {
        pageObserver.accept(calendar.currentPage)
    }

    // 확인
    /// 월간에서 주간으로 변경될 때 표시할 값 계산
    private func sendSelectedDateToTable() {
        guard let preSelectedDate else { return }
        dateSelectionObserver.accept(preSelectedDate)
    }

    // 확인
    /// 스코프 변경하기
    private func changeScope() {
        let scope: FSCalendarScope = calendar.scope == .month ? .week : .month
        calendar.setScope(scope, animated: true)
    }

    /// Month일 때 Week 스코프로 전환
    private func changeWeekScope(animated: Bool) {
        guard calendar.scope == .month else { return }
        calendar.setScope(.week, animated: animated)
    }
    
    /// Week일 때 Month 스코프로 전환
    private func changeMonthScope(animated: Bool) {
        guard calendar.scope == .week else { return }
        calendar.setScope(.month, animated: animated)
    }

    /// Home에서 더보기를 통해서 캘린더로 넘어온 경우
    /// Home에서 표시한 마지막 Event 표시
    private func presentDate(on date: Date) {
        let delay: Int = calendar.scope == .month ? 200 : 0
        changeWeekScope(animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay), execute: {
            self.selectedPresnetDate(on: date)
            self.dateSelectionObserver.accept(date)
        })
    }
}

// MARK: - 셀 업데이트
extension CalendarViewController {
    /// 이벤트 업데이트
    /// - Parameter dateComponents: 서버로부터 받아온 DateComponents
    private func updateEvents(with events: [Date]) {
        self.events = events
        calendar.reloadData()
    }

    // 확인
    /// 선택 여부에 따라서 셀 컬러 변경
    /// - Parameters:
    ///   - date: 선택된 날짜
    ///   - isSelected: 선택 or 선택됐던 셀
    private func updateCell(on date: Date, isSelected: Bool) {
        guard let cell = calendar.cell(for: date, at: .current) as? CustomCalendarCell else {
            return
        }
        cell.updateCell(isSelected: isSelected,
                        isToday: DateManager.isSameDay(date, Date()))
    }

    // 확인
    /// 선택된 셀 구분
    private func checkSelected(on date: Date) -> Bool {
        guard let selectedDate = calendar.selectedDate else { return false }
        return DateManager.isSameDay(date, selectedDate)
    }
}

// MARK: - 특정 위치로 이동
extension CalendarViewController {

    /// 페이지 이동하기
    private func moveToPage(on date: Date, animated: Bool = false) {
        isSystemDragging = true
        calendar.setScope(.month, animated: false)
        self.calendar.setCurrentPage(date, animated: animated)
        isSystemDragging = false
    }

    /// 선택할 날짜가 현재 캘린더의 날짜에 포함되어 있다면 reloadData
    /// 선택되어 있지 않다면 scrollToDate
    private func selectedPresnetDate(on date: Date) {
        self.preSelectedDate = date
        self.calendar.select(date, scrollToDate: false)
        if DateManager.isSameWeek(date, calendar.currentPage) {
            self.calendar.reloadData()
        } else {
            self.calendar.setCurrentPage(date, animated: false)
        }
    }
}

// MARK: - Gesture
extension CalendarViewController {
    enum GestureDirection {
        case vertical
        case horizontal
    }

    enum PagingResult {
        case stay(offset: CGPoint)
        case move(to: Date)
    }
    
    /// scope에 따라서 다른 제스처 처리
    private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        if case calendar.scope = .month {
            handleGestureWhenMonth(gesture)
        } else {
            handleHorizontalGestrueWhenWeek(gesture)
        }
    }

    /// 제스처 핸들링
    private func handleGestureWhenMonth(_ gesture: UIPanGestureRecognizer) {
        let calendarCollectionView = self.calendar.collectionView!
        let velocity = gesture.velocity(in: self.parent?.view)
        let isPanningVertically = abs(velocity.y) > abs(velocity.x)
        if gestureDirection == nil {
            gestureDirection = isPanningVertically ? .vertical : .horizontal
        }

        if gestureDirection == .vertical {
            self.handleVerticalGestrueWhenMonth(gesture)
        } else {
            self.handleHorizontalGestrueWhenMonth(gesture: gesture,
                                                  calendarCollectionView: calendarCollectionView)
        }
    }

    /// 세로 스크롤 핸들링
    /// 시작 지점에서 선택해놓지 않으면 애니메이션이 해당 주간으로 맞춰지지 않음
    private func handleVerticalGestrueWhenMonth(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.setFoucsDate()
        case .ended:
            self.sendSelectedDateToTable()
            self.gestureDirection = nil
        default:
            break
        }

        self.calendar.handleScopeGesture(gesture)
        self.handleEmptyMonthEvent()
    }

    /// 가로 스크롤 핸들링
    private func handleHorizontalGestrueWhenMonth(gesture: UIPanGestureRecognizer,
                                                  calendarCollectionView: UICollectionView) {
        let currentOffset = calendarCollectionView.contentOffset
        let velocity = gesture.velocity(in: self.parent?.view)
        let translation = gesture.translation(in: self.parent?.view)

        switch gesture.state {
        case .began:
            horizonGestureCount += 1
            startCalendarOffset = currentOffset
        case .changed:
            handleCalendarScrollGesture(calendarCollectionView: calendarCollectionView,
                                        currentOffset: currentOffset,
                                        translation: translation)
            gesture.setTranslation(.zero, in: self.parent?.view)
        case .ended:
            self.handleMonthPagingGesture(gesture: gesture,
                                          calendarCollectionView: calendarCollectionView,
                                          currentOffset: currentOffset,
                                          velocity: velocity)
        default:
            break
        }
    }

    /// 제스처의 이동거리를 계산 후 캘린더 넘겨주기
    /// - Parameters:
    ///   - calendarCollectionView: 캘린더의 컬렉션뷰
    ///   - currentOffset: 캘린더의 현재 위치
    ///   - translation: 이동거리
    private func handleCalendarScrollGesture(calendarCollectionView: UICollectionView,
                                             currentOffset: CGPoint,
                                             translation: CGPoint) {
        let destinationsOffset = CGPoint(x: currentOffset.x - translation.x, y: currentOffset.y)
        calendarCollectionView.setContentOffset(destinationsOffset, animated: false)
    }


    /// 제스처의 이동거리, 가속도를 계산 후 페이징 처리
    /// - Parameters:
    ///   - calendarCollectionView: 캘린더의 컬렉션뷰
    ///   - currentOffset: 제스처를 끝낸 시점의 offset
    ///   - velocity: 제스처의 가속도
    private func handleMonthPagingGesture(gesture: UIPanGestureRecognizer,
                                          calendarCollectionView: UICollectionView,
                                          currentOffset: CGPoint,
                                          velocity: CGPoint) {
        guard let startOffset = startCalendarOffset else { return }
        let currentPageDate = self.calendar.currentPage
        let thresholdDistance = calendarCollectionView.bounds.width * 0.5
        let distanceX = currentOffset.x - startOffset.x
        guard abs(distanceX) >= thresholdDistance || abs(velocity.x) > 300.0 else {
            self.pagingResultAnimationGesture(result: .stay(offset: startOffset),
                                              gesture: gesture)
            return
        }
        let isNext = startOffset.x < currentOffset.x
        let destinationDate = isNext ? DateManager.getNextMonth(currentPageDate) : DateManager.getPreviousMonth(currentPageDate)
        self.pagingResultAnimationGesture(result: .move(to: destinationDate),
                                          gesture: gesture)
    }

    /// 결과에 따라서 현재 달력으로 되돌리거나, 달력 전환을 하는 애니메이션 실행
    private func pagingResultAnimationGesture(result: PagingResult,
                                              gesture: UIPanGestureRecognizer) {
        let currentCount = horizonGestureCount
        UIView.animate(withDuration: 0.33,
                       delay: 0,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
            self.handlePage(result)
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard self?.horizonGestureCount == currentCount else { return }
            self?.gestureDirection = nil
            self?.horizonGestureCount = 0
        })
    }

    /// 결과에 따라서 현재 달력으로 되돌리거나, 달력 전환
    private func handlePage(_ result: PagingResult) {
        switch result {
        case .stay(let startOffset):
            calendar.collectionView.setContentOffset(startOffset, animated: false)
        case .move(let pageDate):
            calendar.setCurrentPage(pageDate, animated: false)
        }
    }

    /// Week Scope에서 우측으로 제스처 시 뷰 전환하기
    private func handleHorizontalGestrueWhenWeek(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .ended,
              gesture.translation(in: self.parent?.view).x > 50.0 else { return }
        self.changeScope()
        self.sendCurrentPageToHeader()
    }
}
// MARK: - Helper
extension CalendarViewController {

    /// 이번달의 선택된 날짜또는 첫번째 이벤트 PreSelected로 설정
    private func setPreSelectedDateWhenMonth() {
        guard calendar.scope == .month else { return }
        preSelectedDate = selectedDateInCurrentMonth()
        ?? findFirstEvent(on: calendar.currentPage)
        ?? findSmallestNextMonth(on: calendar.currentPage)
        ?? findLargestPreviousDate(on: calendar.currentPage)
    }

    /// 선택된 날짜가 있고, 그게 현재달이 아닐 시 scroll
    private func handleEmptyMonthEvent() {
        guard calendar.scope == .week,
              let preSelectedDate = preSelectedDate,
              !DateManager.isSameWeek(calendar.currentPage, preSelectedDate) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350), execute: {
            self.calendar.setCurrentPage(preSelectedDate, animated: true)
        })
    }

    /// 이번달에 존재하는 날짜인지 체크
    /// - Parameter date: 체크할 날짜
    private func selectedDateInCurrentMonth() -> Date? {
        guard let date = calendar.selectedDate,
              DateManager.isSameMonth(calendar.currentPage, date) else { return nil }

        return date
    }

    /// calendar.selectedDate가 nil이라면 preSelectedDate 선택
    /// calendar.selectedDate가 nil이 아니고 preSelectedDate와 다른 달이라면 preSelectedDate 선택
    private func setFoucsDate() {
        guard calendar.scope == .month,
              calendar.selectedDate != preSelectedDate else { return }
        calendar.select(preSelectedDate, scrollToDate: false)
    }

    /// 기본값으로 첫 이벤트 preSelectedDate에 할당
    private func setDefaulsePreDate() {
        let currentDate = calendar.currentPage
        preSelectedDate = findFirstEvent(on: currentDate)
        ?? findSmallestNextMonth(on: currentDate)
        ?? findLargestPreviousDate(on: currentDate)
        deSelectedDate()
    }
    
    private func deSelectedDate() {
        guard let selectedDate = calendar.selectedDate else { return }
        calendar.deselect(selectedDate)
    }
    
    private func findFirstEvent(on date: Date) -> Date? {
        let currentMonthDate = events.filter({ DateManager.isSameMonth($0, date) })
        let activeEvent = currentMonthDate.filter { DateManager.isFutureOrToday(on: $0) }
        return activeEvent.min() ?? currentMonthDate.max()
    }
    
    /// date보다 과거 이벤트 중 가장 큰 것
    private func findLargestPreviousDate(on date: Date) -> Date? {
        return events.filter { $0 < date }.max()
    }
    
    /// date보다 미래 이벤트 중 가장 작은 것
    private func findSmallestNextMonth(on date: Date) -> Date? {
        return events.filter { $0 > date }.min()
    }
}


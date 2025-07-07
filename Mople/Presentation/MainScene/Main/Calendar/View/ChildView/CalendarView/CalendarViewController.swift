//
//  CalendarViewController.swift
//  Group
//
//  Created by CatSlave on 9/13/24.
//

import UIKit
import SnapKit
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
    private let topInset: CGFloat = 16
    private let weekHeaderHeight: CGFloat = 36
    private let weekDayVerticalPadding: CGFloat = 5
    private let defaultHorizonPadding: CGFloat = 24
    private let grabberHeight: CGFloat = 41
    private let lineHeight: CGFloat = 1
    private var preSelectedDate: Date?
    private let currentCalendar = DateManager.calendar
    private var events: [Date] = []
    private var holidays: [Date] = []
    private var isSystemDragging: Bool = false

    // MARK: - Observable
    fileprivate let scopeObserver: PublishRelay<ScopeType> = .init()
    fileprivate let pageObserver: PublishRelay<Date> = .init()
    fileprivate let selectedDateObserver: PublishRelay<Date> = .init()
    fileprivate let heightObserver: PublishRelay<CGFloat> = .init()
    private let yearObserver: PublishRelay<Int> = .init()
    
    // MARK: - Gestrue
    private var gestureDirection: GestureDirection?
    private var startCalendarOffset: CGPoint?
    private var horizonGestureCount: Int = 0

    // MARK: - UI Components
    private let topInsetView: UIView = {
        let view = UIView()
        view.backgroundColor = .defaultWhite
        return view
    }()
    
    public lazy var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.backgroundColor = .defaultWhite
        calendar.scrollDirection = .horizontal
        calendar.adjustsBoundingRectWhenChangingMonths = false
        calendar.placeholderType = .none
        calendar.headerHeight = 0
        calendar.layer.zPosition = 1
        // FSCalendar 섹션 기본값 (5, 0, 5, 0)
        calendar.collectionViewLayout.sectionInsets = .init(top: weekDayVerticalPadding,
                                                            left: defaultHorizonPadding,
                                                            bottom: weekDayVerticalPadding,
                                                            right: defaultHorizonPadding)
        return calendar
    }()

    private let weekContainerView = UIView()
    
    private let grabberBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .bgPrimary
        return view
    }()

    private let grabberContainer: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.layer.makeCornes(radius: 20, corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        view.clipsToBounds = true
        view.backgroundColor = .defaultWhite
        return view
    }()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = .appTertiary
        view.layer.cornerRadius = 3
        view.isHidden = true
        return view
    }()
    
    // MARK: - Gesture
    private let panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer()
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()

    // MARK: - LifeCycle
    init(reactor: CalendarViewReactor) {
        super.init()
        self.reactor = reactor
        self.view.clipsToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setCalendar()
        setLayout()
        scopeBind()
        setPanGesture()
    }
    
    private func setLayout() {
        view.backgroundColor = .defaultWhite
        view.addSubview(topInsetView)
        view.addSubview(calendar)
        view.addSubview(grabberBackView)
        grabberBackView.addSubview(grabberContainer)
        grabberContainer.addSubview(grabberView)

        calendar.addSubview(weekContainerView)
        weekContainerView.addSubview(calendar.calendarWeekdayView)
        
        topInsetView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(topInset)
        }

        calendar.snp.makeConstraints { make in
            make.top.equalTo(topInsetView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(280 + weekHeaderHeight)
        }

        weekContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(defaultHorizonPadding)
            make.height.equalTo(weekHeaderHeight)
        }

        calendar.calendarWeekdayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        grabberBackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(grabberHeight + lineHeight)
        }
        
        grabberContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(lineHeight)
        }
        
        grabberView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
            make.width.equalTo(80)
            make.height.equalTo(5)
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
        calendar.appearance.titleFont = FontStyle.Title3.semiBold
        calendar.appearance.weekdayFont = FontStyle.Body1.medium
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = .clear
    }

    // MARK: - Gesture Setup
    private func setPanGesture() {
        self.view.addGestureRecognizer(panGesture)
        
        panGesture.rx.event
            .bind(with: self, onNext: { vc, gesture in
                vc.handleGesture(gesture)
            })
            .disposed(by: disposeBag)
    }
    
    private func scopeBind() {
        scopeObserver
            .bind(with: self, onNext: { vc, scope in
                vc.updateGrabberBackColor(scope)
                vc.updateGrabberVisible(scope)
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
        yearObserver
            .distinctUntilChanged()
            .map { Reactor.Action.fetchHolidays(year: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$events)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, events in
                vc.events = events
                vc.setDefaulsePreDate()
            })
            .disposed(by: disposeBag)
     
        reactor.pulse(\.$holidays)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, holidays in
                vc.holidays = holidays
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$completedLoad)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, _ in
                vc.calendar.reloadData()
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
        updateCurrentYear()
        syncCurrentPage()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return events.contains(where: { DateManager.isSameDay($0, date) })
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        preSelectedDate = date
        updateCell(on: date, isSelected: true)
        if calendar.scope == .month {
            switchScope(type: .dateTap)
        } else {
            sendSelectedDateToTable()
        }
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        guard events.contains(where: { DateManager.isSameDay($0, date) }) else { return }
        updateCell(on: date, isSelected: false)
    }

    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        let currentScope: ScopeType = calendar.scope == .month ? .month : .week
        // month -> scope 변경 시 요일헤더 인셋 값 / 2으로 적용
        let halfWeekDayVerticalPadding: CGFloat = weekDayVerticalPadding / 2
        let calculateGrabberHeight = grabberHeight - lineHeight
        self.scopeObserver.accept(currentScope)
        self.heightObserver.accept(bounds.height + halfWeekDayVerticalPadding + calculateGrabberHeight)
        self.calendar.snp.updateConstraints { make in
            make.height.equalTo(bounds.height)
        }
        self.view.layoutIfNeeded()
    }
}

extension CalendarViewController: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        switch date {
        case _ where events.contains(where: { DateManager.isSameDay($0, date) }):
            return isHoliday(date) ? .defaultRed : .gray01
        default :
            return isHoliday(date) ? .defaultRed1 : .gray07
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        switch date {
        case _ where events.contains(where: { DateManager.isSameDay($0, date) }):
            return isHoliday(date) ? .defaultRed : .gray01
        default :
            return isHoliday(date) ? .defaultRed1 : .gray07
        }
    }
    
    private func isEventDay(_ day: Date) -> Bool {
        return events.contains(where: { DateManager.isSameDay($0, day) })
    }
    
    private func isHoliday(_ day: Date) -> Bool {
        return holidays.contains(where: { DateManager.isSameDay($0, day) }) || DateManager.isSunday(day)
    }
}

// MARK: - UI Update
extension CalendarViewController {
    private func updateGrabberBackColor(_ scope: ScopeType) {
        self.grabberBackView.backgroundColor = scope == .month ? .defaultWhite : .bgPrimary
    }
    
    private func updateGrabberVisible(_ scope: ScopeType) {
        self.grabberView.isHidden = scope == .month
    }
}

// MARK: - 스코프 업데이트
extension CalendarViewController {
    
    enum ScopeChangeType {
        case buttonTap
        case dateTap
    }

    /// 스위치 방식에 따라서 처리
    /// 포커싱 할 date PostListViewController에게 알리기
    public func switchScope(type: ScopeChangeType) {
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
            changeWeekScope(animated: true)
        }
    }

    private func scopeSync() {
        switch calendar.scope {
        case .month:
            syncCurrentPage()
        case .week:
            sendSelectedDateToTable()
        @unknown default:
            break
        }
    }

    private func syncCurrentPage() {
        guard !isSystemDragging else { return }
        pageObserver.accept(calendar.currentPage)
    }

    // 확인
    /// 월간에서 주간으로 변경될 때 표시할 값 계산
    private func sendSelectedDateToTable() {
        guard let preSelectedDate else { return }
        selectedDateObserver.accept(preSelectedDate)
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
}

// MARK: - 셀 업데이트
extension CalendarViewController {

    /// 연도가 바뀔 때 공유
    private func updateCurrentYear() {
        let currentDate = calendar.currentPage
        let currentYear = DateManager.weekBasedYear(currentDate)
        yearObserver.accept(currentYear)
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
        guard events.contains(where: { DateManager.isSameDay($0, date) }),
              let selectedDate = calendar.selectedDate else { return false }
        return DateManager.isSameDay(date, selectedDate)
    }
}

// MARK: - 특정 위치로 이동
extension CalendarViewController {

    /// 페이지 이동하기
    public func moveToPage(on date: Date, animated: Bool = false) {
        isSystemDragging = true
        calendar.setScope(.month, animated: false)
        self.calendar.setCurrentPage(date, animated: animated)
        isSystemDragging = false
    }

    /// 선택할 날짜가 현재 캘린더의 날짜에 포함되어 있다면 reloadData
    /// 선택되어 있지 않다면 scrollToDate
    public func selectedPresnetDate(on date: Date) {
        isSystemDragging = true
        self.preSelectedDate = date
        self.calendar.select(date, scrollToDate: false)
        if DateManager.isSameWeek(date, calendar.currentPage) {
            self.calendar.reloadData()
        } else {
            self.calendar.setCurrentPage(date, animated: true)
        }
        isSystemDragging = false
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

    /// 제스처 핸들링
    private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: self.parent?.view)
        let isPanningVertically = abs(velocity.y) > abs(velocity.x)
        
        if gestureDirection == nil {
            gestureDirection = isPanningVertically ? .vertical : .horizontal
        }
        
        if calendar.scope == .month {
            handleGestureWhenMonth(gesture: gesture)
        } else {
            verticalGestrue(gesture)
        }
    }

    private func handleGestureWhenMonth(gesture: UIPanGestureRecognizer) {
        if gestureDirection == .vertical {
            self.verticalGestrue(gesture)
        } else {
            self.handleHorizontalGestrue(gesture: gesture,
                                         calendarCollectionView: self.calendar.collectionView!)
        }
    }
    
    /// 세로 스크롤 핸들링
    /// 시작 지점에서 선택해놓지 않으면 애니메이션이 해당 주간으로 맞춰지지 않음
    private func verticalGestrue(_ gesture: UIPanGestureRecognizer) {
        startVerticalGesture(gesture)
        calendar.handleScopeGesture(gesture)
        endVerticalGesture(gesture)
    }
    
    private func startVerticalGesture(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .began, calendar.scope == .month else { return }
        self.setFoucsDate()
    }
    
    private func endVerticalGesture(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .ended else { return }
        if calendar.scope == .month {
            self.syncCurrentPage()
        } else {
            self.sendSelectedDateToTable()
        }
        self.handleEmptyMonthEvent()
        self.gestureDirection = nil
    }

    /// 가로 스크롤 핸들링
    private func handleHorizontalGestrue(gesture: UIPanGestureRecognizer,
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
}
// MARK: - Helper
extension CalendarViewController {
    
    /// 선택된 날짜가 있고, 그게 현재달이 아닐 시 scroll
    private func handleEmptyMonthEvent() {
        guard calendar.scope == .week,
              let preSelectedDate = preSelectedDate,
              !DateManager.isSameWeek(calendar.currentPage, preSelectedDate) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350), execute: {
            self.calendar.setCurrentPage(preSelectedDate, animated: true)
        })
    }

    /// 이번달의 선택된 날짜또는 첫번째 이벤트 PreSelected로 설정
    private func setPreSelectedDate() {
        preSelectedDate = getSelectedDateInCurrentPage()
        ?? getFirstEventInCurrentPage()
        ?? findSmallestNextMonth(on: calendar.currentPage)
        ?? findLargestPreviousDate(on: calendar.currentPage)
    }

    /// calendar.selectedDate가 nil이라면 preSelectedDate 선택
    /// calendar.selectedDate가 nil이 아니고 preSelectedDate와 다른 달이라면 preSelectedDate 선택
    private func setFoucsDate() {
        setPreSelectedDate()
        guard calendar.selectedDate != preSelectedDate else { return }
        calendar.select(preSelectedDate, scrollToDate: false)
    }

    /// 기본값으로 첫 이벤트 preSelectedDate에 할당
    private func setDefaulsePreDate() {
        guard calendar.scope == .month else { return }
        let currentDate = calendar.currentPage
        preSelectedDate = getFirstEventInCurrentPage()
        ?? findSmallestNextMonth(on: currentDate)
        ?? findLargestPreviousDate(on: currentDate)
        deSelectedDate()
    }
    
    private func deSelectedDate() {
        guard let selectedDate = calendar.selectedDate else { return }
        calendar.deselect(selectedDate)
    }
    
    /// 이번달에 존재하는 날짜인지 체크
    /// - Parameter date: 체크할 날짜
    private func getSelectedDateInCurrentPage() -> Date? {
        guard let date = calendar.selectedDate,
              DateManager.isSameMonth(calendar.currentPage, date) else { return nil }
        return date
    }
    
    private func getFirstEventInCurrentPage() -> Date? {
        let visibleEvents = events.filter({ DateManager.isSameMonth($0, calendar.currentPage) })
        let activeEvents = visibleEvents.filter { DateManager.isFutureOrToday(on: $0) }
        return activeEvents.min() ?? visibleEvents.max()
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

extension Reactive where Base: CalendarViewController {
    var height: Observable<CGFloat> {
        return base.heightObserver
            .observe(on: MainScheduler.asyncInstance)
            .asObservable()
    }
    
    var scope: Observable<ScopeType> {
        return base.scopeObserver
            .observe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
    }
    
    var month: Observable<Date> {
        return base.pageObserver
            .observe(on: MainScheduler.asyncInstance)
    }
    
    var selectedDate: Observable<Date> {
        return base.selectedDateObserver
            .observe(on: MainScheduler.asyncInstance)
            .asObservable()
    }
}

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

enum ScopeChangeType {
    case gesture
    case tap
}

final class CalendarViewController: UIViewController, View {
        
    typealias Reactor = CalendarViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private let currentCalendar = DateManager.calendar
    private var events: [Date] = []
    private var selectedDay: Date?
    
    // MARK: - Observable
    private let gestureObserver: Observable<UIPanGestureRecognizer>
    private let heightObserver: PublishRelay<CGFloat> = .init()
    private let scopeObserver: PublishRelay<ScopeType> = .init()
    private let pageObserver: PublishRelay<DateComponents> = .init()
    private let dateSelectionObserver: PublishRelay<DateComponents?> = .init()
    
    // MARK: - UI Components
    private let calendar: FSCalendar = {
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
    init(reactor: CalendarViewReactor,
         gestureObserver: Observable<UIPanGestureRecognizer>) {
        self.gestureObserver = gestureObserver
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        super.viewDidLoad()
        setCalendar()
        setupUI()
        setGestureObserver()
    }

    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = AppDesign.defaultWihte
        self.view.addSubview(calendar)
        
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
        calendar.appearance.weekdayTextColor = AppDesign.Calendar.weekTextColor
        calendar.appearance.titleTodayColor = .init(hexCode: "DDDDDD")
        calendar.appearance.titleSelectionColor = .init(hexCode: "222222")
        calendar.appearance.titleDefaultColor = .init(hexCode: "DDDDDD")
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = .clear
        calendar.appearance.titleFont = AppDesign.Calendar.dayFont
        calendar.appearance.weekdayFont = AppDesign.Calendar.weekFont
    }
    
    // MARK: - Binding
    func bind(reactor: CalendarViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func outputBind(_ reactor: Reactor) {
        heightObserver
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.calendarHeightChanged(height: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        scopeObserver
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.scopeChanged(scope: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pageObserver
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.pageChanged(page: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        dateSelectionObserver
            .observe(on: MainScheduler.instance)
            .compactMap({ $0 })
            .map { Reactor.Action.dateSelected(dateComponents: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func inputBind(_ reactor: Reactor) {
        
        reactor.pulse(\.$calendarHeight)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, height in
                vc.updateHeight(height)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$switchScope)
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, type in
                vc.switchScope(type: type)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$events)
            .filter({ !$0.isEmpty })
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, events in
                vc.updateEvents(with: events)
                vc.setDefaultDate()
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$switchPage)
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, dateComponents in
                vc.moveToPage(dateComponents: dateComponents)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$tableViewDate)
            .observe(on: MainScheduler.instance)
            .debounce(.milliseconds(10), scheduler: MainScheduler.instance)
            .pairwise()
            .filter({ $0 != $1 })
            .subscribe(with: self, onNext: { vc, datePair  in
                vc.moveToTableDate(datePair)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$presentDate)
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, date in
                vc.presentDate(on: date)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Set Observer
    
    /// 상위뷰에서 제스처 동작이 들어온 경우
    private func setGestureObserver() {
        self.gestureObserver
            .subscribe(with: self, onNext: { vc, gesture in
                vc.calendar.handleScopeGesture(gesture)
            })
            .disposed(by: disposeBag)
    }
}

extension CalendarViewController: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: CustomCalendarCell.reuseIdentifier, for: date, at: position) as! CustomCalendarCell
        cell.updateCell(containsEvent: checkContainsEvent(date),
                        isSelected: checkSelected(on: date, at: position),
                        isToday: checkToday(date))
        return cell
    }
}

// MARK: - Delegate
extension CalendarViewController: FSCalendarDelegate {
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        var components = Date().getComponents()
        components.month = 1
        components.day = 1
        let date = components.getDate() ?? Date()
        return currentCalendar.date(byAdding: .year, value: -10, to: date) ?? Date()
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        var components = Date().getComponents()
        components.month = 12
        components.day = 31
        let date = components.getDate() ?? Date()
        return currentCalendar.date(byAdding: .year, value: 10, to: date) ?? Date()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        pageObserver.accept(calendar.currentPage.getComponents())
        selectedFirstEvent()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return events.contains { DateManager.isSameDay($0, date) }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(#function, #line)
        selectedDay = date
        updateFocus(on: date, with: monthPosition)
        updateCell(date, isSelected: true)
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(#function, #line)
        updateCell(date, isSelected: false)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        let maxHeight = calendar.rowHeight * 6
        let currentScope: ScopeType = calendar.scope == .month ? .month : .week
        let resultHeight = calendar.scope == .month ? maxHeight : bounds.height
        self.scopeObserver.accept(currentScope)
        self.heightObserver.accept(resultHeight)
    }
}

extension CalendarViewController: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        guard events.contains(where: { DateManager.isSameDay($0, date) }) else { return .init(hexCode: "999999") }
        print("이벤트 : \(date)")
        return AppDesign.defaultBlack
        
//        return .darkGray//events.contains(date) ? AppDesign.defaultBlack : nil
    }
}

// MARK: - 셀 선택 시 액션
extension CalendarViewController {
    
    /// 셀 선택 시 달력의 타입에 따른 액션 처리
    private func updateFocus(on date: Date, with position: FSCalendarMonthPosition) {
        switch calendar.scope {
        case .month:
            changeMonth(on: date, with: position)
        case .week:
            notifySelectedDate(on: date)
        @unknown default:
            break
        }
    }
    
    /// 월 단위의 달력에서 선택한 날짜의 타입에 따른 액션 처리
    private func changeMonth(on date: Date, with monthPosition: FSCalendarMonthPosition) {
        guard calendar.scope == .month else { return }
        switch monthPosition {
        case .current:
            switchScope(type: .tap)
        case .next, .previous:
            let dateComponents = date.getComponents()
            self.moveToPage(dateComponents: dateComponents, animated: true)
        default:
            break
        }
    }
    
    /// 스케줄 테이블 반영
    private func notifySelectedDate(on date: Date) {
        let date = date.getComponents()
        dateSelectionObserver.accept(date)
    }
}

// MARK: - 스코프 업데이트
extension CalendarViewController {
    
    /// 스코프에 맞춰서 캘린더 뷰 높이 조절
    private func updateHeight(_ height: CGFloat) {
        calendar.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        
        view.layoutIfNeeded()
    }
    
    /// 스코프 전환
    /// - Parameter type: Gesture Or Tap
    private func switchScope(type: ScopeChangeType) {
        if type == .tap {
            changeScope()
        }
        scopeSync()
    }
    
    /// scope에 맞춰서 표시할 데이터 동기화
    /// month : week에서 previous, current, next 날짜 클릭에 따라서 calenar가 맞는 날짜를 표시해줌
    private func scopeSync() {
        switch calendar.scope {
        case .month:
            updateWhenMonthScope()
        case .week:
            updateWhenWeekScope()
        @unknown default:
            break
        }
    }
    
    /// 주간에서 월간으로 변경할 때 DatePicker, MainHeaderLabel 반영을 위해서 pageObserver에 값 보내기
    private func updateWhenMonthScope() {
        pageObserver.accept(calendar.currentPage.getComponents())
    }
    
    /// 월간에서 주간으로 변경될 때 표시할 값 계산
    private func updateWhenWeekScope() {
        guard let selectedDate = calendar.selectedDate else { return }
        selectedDay = selectedDate
        dateSelectionObserver.accept(selectedDate.getComponents())
    }
    
    /// 스코프 변경하기
    private func changeScope() {
        let scope: FSCalendarScope = calendar.scope == .month ? .week : .month
        calendar.setScope(scope, animated: true)
    }
    
    /// Month인 경우에만 Week으로 전환
    private func changeWeekScope(animated: Bool) {
        guard calendar.scope == .month else { return }
        calendar.setScope(.week, animated: animated)
    }
    
    /// Home에서 더보기를 통해서 캘린더로 넘어온 경우
    /// Home에서 표시한 마지막 Event 표시
    private func presentDate(on date: DateComponents) {
        print(#function, #line)
        let delay: Int = calendar.scope == .month ? 200 : 0
        selectedDay = date.getDate()
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

    /// 선택 여부에 따라서 셀 컬러 변경
    /// - Parameters:
    ///   - date: 선택된 날짜
    ///   - isSelected: 선택 or 선택됐던 셀
    private func updateCell(_ date: Date, isSelected: Bool) {
        guard let cell = calendar.cell(for: date, at: .current) as? CustomCalendarCell else {
            return
        }
        cell.updateCell(containsEvent: checkContainsEvent(date),
                        isSelected: isSelected,
                        isToday: checkToday(date))
    }
    
    /// 이벤트 셀 구분
    private func checkContainsEvent(_ date: Date) -> Bool {
        return events.contains { $0 == date }
    }
    
    /// 선택된 셀 구분
    private func checkSelected(on day: Date, at position: FSCalendarMonthPosition) -> Bool {
        guard let selectedDay = selectedDay else { return false }
        return selectedDay == day && position == .current
    }
    
    /// 오늘 날짜 셀 구분
    private func checkToday(_ date: Date) -> Bool {
        let targetComponents = date.getComponents()
        return targetComponents == Date().getComponents()
    }
}

// MARK: - 특정 위치로 이동
extension CalendarViewController {
    
    /// 페이지 이동하기
    private func moveToPage(dateComponents: DateComponents, animated: Bool = false) {
        guard let date = dateComponents.getDate() else { return }
        self.calendar.setCurrentPage(date, animated: animated)
    }
    
    /// 테이블뷰에서 표시하는 날짜와 표시되는 날짜 동기화
    private func moveToTableDate(_ datePair: (DateComponents?, DateComponents?)) {
        let dates = [datePair.0, datePair.1].compactMap { $0 }
        guard let tableDateComponents = dates.last,
              let tableDate = tableDateComponents.getDate() else { return }
        self.selectedDay = tableDate
        selectedPresnetDate(on: tableDateComponents)
    }
    
    /// 선택할 날짜가 현재 캘린더의 날짜에 포함되어 있다면 reloadData
    /// 선택되어 있지 않다면 scrollToDate
    private func selectedPresnetDate(on dateComponents: DateComponents) {
        guard let date = dateComponents.getDate() else { return }
        if DateManager.isSameWeek(date, calendar.currentPage) {
            self.calendar.select(date, scrollToDate: false)
            self.calendar.reloadData()
        } else {
            self.calendar.select(date, scrollToDate: true)
        }
    }
}


// MARK: - Helper
extension CalendarViewController {
    
    /// 월 단위에서 페이지 이동 시 셀 선택하기
    private func selectedFirstEvent() {
        guard calendar.scope == .month else { return }
        calendar.select(currentPagePresentDate(), scrollToDate: false)
    }
    
    /// 현재 페이지에서 선택된 날짜 및 첫 이벤트
    private func currentPagePresentDate() -> Date? {
        if hasSelectedDateInCurrentView() {
            return calendar.selectedDate
        } else {
            return currentPageFirstEventDate()
        }
    }
    
    /// 현재 캘린더 뷰에서 선택된 날짜가 있는지 체크
    private func hasSelectedDateInCurrentView() -> Bool {
        guard let selectedDate = calendar.selectedDate else { return false }
        return DateManager.isSameMonth(calendar.currentPage, selectedDate)
    }
    
    /// 현재 달력에서 표시할 날짜 구하기
    /// 첫 이벤트가 있는 경우 첫 이벤트 return
    /// 이벤트가 없고 이번달인 경우 today return
    /// 그 외 1일 return
    private func getPresentDate() -> Date? {
        if let firstEvent = currentPageFirstEventDate() {
            return firstEvent
        } else {
            return isCurrentMonth() ? Date() : calendar.currentPage
        }
    }
    
    /// 현재 달력에서 첫번째 이벤트
    private func currentPageFirstEventDate() -> Date? {
        let currentPageEvnet = events.filter { DateManager.isSameMonth($0, self.calendar.currentPage) }
        
        guard let firstEvent = currentPageEvnet.first else { return nil }
        return firstEvent
    }
    
    /// 현재 페이지가 이번 달인지 체크
    private func isCurrentMonth() -> Bool {
        return DateManager.isSameMonth(Date(), calendar.currentPage)
    }
    
    /// 첫 진입 시 선택할 날짜
    private func setDefaultDate() {
        calendar.select(getPresentDate(), scrollToDate: false)
    }
}

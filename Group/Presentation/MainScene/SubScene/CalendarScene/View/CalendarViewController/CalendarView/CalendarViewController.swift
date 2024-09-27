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
import FSCalendar

enum ScopeType {
    case week
    case month
}

final class CalendarViewController: UIViewController {
        
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private let currentCalendar = DateManager.calendar
    private let todayComponents: DateComponents
    private var eventDateComponents: [DateComponents] = []
    
    // MARK: - Observable
    
    // Internal State Observable
    private let calendarFocusDateObservable: PublishSubject<DateComponents> = .init()
    
    // Output
    private let heightObservable: AnyObserver<CGFloat>
    private let scopeObservable: AnyObserver<ScopeType>
    private let pageChangeNotificationObserver: AnyObserver<DateComponents>
    private let foucsChangeNotificationObserver: AnyObserver<DateComponents>
    
    // Input
    private let scopeChangeObservable: Observable<Void>
    private let eventArrayObservable: Observable<[DateComponents]>
    
    // Input Internal
    private let pageChangeRequestObserver: PublishSubject<DateComponents>
    
    // Input/Output
    private let dateObservable: Observable<DateComponents>
    
    // MARK: - UI Components
    private let calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.scrollDirection = .horizontal
        calendar.adjustsBoundingRectWhenChangingMonths = true
        calendar.placeholderType = .fillHeadTail
        calendar.headerHeight = 0
        calendar.rowHeight = 60
        calendar.collectionViewLayout.sectionInsets = .init(top: 5, left: 24, bottom: 5, right: 24)
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }()
    
    private let weekContainerView = UIView()
    
    // MARK: - LifeCycle
    init(todayComponents: DateComponents,
         heightObservable: AnyObserver<CGFloat>,
         scopeObservable: AnyObserver<ScopeType>,
         pageChangeNotificationObserver: AnyObserver<DateComponents>,
         foucsChangeNotificationObserver: AnyObserver<DateComponents>,
         scopeChangeObservable: Observable<Void>,
         eventArrayObservable: Observable<[DateComponents]>,
         pageChangeRequestObserver: PublishSubject<DateComponents>,
         dateObservable: Observable<DateComponents>) {

        self.todayComponents = todayComponents
        self.heightObservable = heightObservable
        self.scopeObservable = scopeObservable
        self.pageChangeNotificationObserver = pageChangeNotificationObserver
        self.foucsChangeNotificationObserver = foucsChangeNotificationObserver
        self.scopeChangeObservable = scopeChangeObservable
        self.eventArrayObservable = eventArrayObservable
        self.pageChangeRequestObserver = pageChangeRequestObserver
        self.dateObservable = dateObservable
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCalendar()
        setupUI()
        setBind()
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
        setCalendarAppearance()
        calendar.delegate = self
        calendar.dataSource = self
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "CustomCell")
    }
    
    private func setCalendarAppearance() {
        calendar.appearance.weekdayTextColor = UIColor(hexCode: "999999")
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = .clear
        calendar.appearance.titleWeekendColor = .systemRed
    }
    
    // MARK: - Binding
    private func setBind() {
        scopeChangeObservable
            .subscribe(with: self, onNext: { vc, _ in
                vc.switchScope()
            })
            .disposed(by: disposeBag)
        
        eventArrayObservable
            .subscribe(with: self, onNext: { vc, events in
                vc.updateEvents(with: events)
            })
            .disposed(by: disposeBag)
        
        pageChangeRequestObserver
            .subscribe(with: self, onNext: { vc, dateComponents in
                vc.moveToPage(dateComponents: dateComponents)
                vc.pageChangeNotificationObserver.onNext(dateComponents)
            })
            .disposed(by: disposeBag)
        
        dateObservable
            .debounce(.milliseconds(10), scheduler: MainScheduler.instance)
            .pairwise()
            .filter(areDatesDistinct)
            .compactMap({ Optional(tuple: $0) })
            .subscribe(with: self, onNext: { vc, datePair  in
                vc.moveToCurrentDate(datePair)
            })
            .disposed(by: disposeBag)
        
        calendarFocusDateObservable
            .debounce(.milliseconds(335), scheduler: MainScheduler.instance)
            .do(onNext: {
                self.foucsChangeNotificationObserver.onNext($0)
            })
            .subscribe(with: self, onNext: { vc, date in
                vc.moveToFoucsDate(date)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - DataSource
extension CalendarViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "CustomCell", for: date, at: position) as! CustomCalendarCell
        cell.updateCell(containsEvent: checkContainsEvent(date),
                        isSelected: checkSelected(date),
                        isToday: checkToday(date))
        return cell
    }
}

// MARK: - Delegate
extension CalendarViewController: FSCalendarDelegate {
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        var components = todayComponents
        components.month = 1
        components.day = 1
        let date = DateManager.convertDate(components) ?? Date()
        return currentCalendar.date(byAdding: .year, value: -10, to: date) ?? Date()
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        var components = todayComponents
        components.month = 12
        components.day = 31
        let date = DateManager.convertDate(components) ?? Date()
        return currentCalendar.date(byAdding: .year, value: 10, to: date) ?? Date()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let updateComponents = DateManager.convertDateComponents(calendar.currentPage)
        pageChangeNotificationObserver.onNext(updateComponents)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        notifySelectedDate(date)
        changeMonth(date: date, with: monthPosition)
        updateCell(date, isSelected: true)
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateCell(date, isSelected: false)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        let maxHeight = calendar.rowHeight * 6
        let currentScope: ScopeType = calendar.scope == .month ? .month : .week
        let resultHeight = calendar.scope == .month ? maxHeight : bounds.height
        
        self.scopeObservable.onNext(currentScope)
        self.heightObservable.onNext(resultHeight)
    }
}

// MARK: - 셀 선택 시 액션
extension CalendarViewController {
    
    
    private func changeMonth(date: Date, with monthPosition: FSCalendarMonthPosition) {
        guard calendar.scope == .month else { return }
        switch monthPosition {
        case .current:
            switchScope()
        case .next, .previous:
            let dateComponents = DateManager.convertDateComponents(date)
            self.moveToPage(dateComponents: dateComponents, animated: true)
        default:
            break
        }
    }
    
    
    /// 스케줄 테이블 반영
    private func notifySelectedDate(_ date: Date) {
        let date = DateManager.convertDateComponents(date)
        foucsChangeNotificationObserver.onNext(date)
    }
}

// MARK: - 스코프 업데이트
extension CalendarViewController {
    /// 스코프 변경
    private func switchScope() {
        changeScope()
        updateWhenMonthScope()
        updateWhenWeekScope()
    }

    /// 스코프 셋팅
    private func changeScope() {
        let changeScope: FSCalendarScope = self.calendar.scope == .month ? .week : .month
        calendar.setScope(changeScope, animated: true)
    }
    
    /// 주간에서 월간으로 변경될 때
    /// 선택된 값이 있는지 판단 후 표시할 값 리턴
    private func updateWhenMonthScope() {
        guard calendar.scope == .month else { return }
        
        if hasSelectedDateInCurrentView() {
            guard let selectedDate = selectedDate() else { return }
            pageChangeRequestObserver.onNext(selectedDate)
        } else {
            pageChangeNotificationObserver.onNext(currentPageDateComponents())
        }
    }
    
    /// 월간에서 주간으로 변경될 때 표시할 값 계산
    private func updateWhenWeekScope() {
        guard calendar.scope == .week else { return }
        
        if hasSelectedDateInCurrentView() {
            guard let selectedDate = selectedDate() else { return }
            calendarFocusDateObservable.onNext(selectedDate)

        } else {
            guard let firstEvent = currentPageFirstEventDateComponents() else { return }
            calendarFocusDateObservable.onNext(firstEvent)
        }
    }
}

// MARK: - 셀 업데이트
extension CalendarViewController {
    /// 이벤트 업데이트
    /// - Parameter dateComponents: 서버로부터 받아온 DateComponents
    private func updateEvents(with dateComponents: [DateComponents]) {
        self.eventDateComponents = dateComponents
        calendar.reloadData()
    }

    /// 선택 여부에 따라서 셀 컬러 변경
    /// - Parameters:
    ///   - date: 선택된 날짜
    ///   - isSelected: 선택된 셀 or 선택됐던 셀
    private func updateCell(_ date: Date, isSelected: Bool) {
        guard let cell = calendar.cell(for: date, at: .current) as? CustomCalendarCell else { return }
        cell.updateCell(containsEvent: checkContainsEvent(date),
                        isSelected: isSelected,
                        isToday: checkToday(date))
    }
    
    /// 일정이 있는 날인지 체크
    private func checkContainsEvent(_ date: Date) -> Bool {
        let dateComponent = currentCalendar.dateComponents([.year, .month, .day], from: date)
        return eventDateComponents.contains { $0 == dateComponent }
    }
    
    /// 셀 그릴 때 선택된 셀 구분
    /// - Parameter date: 그릴려고 하는 날짜
    private func checkSelected(_ date: Date) -> Bool {
        guard let selectedDate = calendar.selectedDate else { return false }
        return selectedDate == date
    }
    
    /// 선택된 셀이 오늘인지 확인
    /// - Parameter date: 선택된 날짜
    private func checkToday(_ date: Date) -> Bool {
        let targetComponents = currentCalendar.dateComponents([.year, .month, .day], from: date)
        
        return targetComponents == todayComponents
    }
}

// MARK: - 특정 위치로 이동
extension CalendarViewController {
    private func moveToPage(dateComponents: DateComponents, animated: Bool = false) {
        if let date = currentCalendar.date(from: dateComponents) {
            self.calendar.setCurrentPage(date, animated: animated)
        }
    }
    
    private func moveToCurrentDate(_ datePair: (DateComponents, DateComponents)) {
        guard let previousDate = DateManager.convertDate(datePair.0),
              let currentDate = DateManager.convertDate(datePair.1) else { return }
        
        guard let focusDate = currentCalendar.date(from: datePair.1) else { return }
        
        calendar.select(focusDate, scrollToDate: false)
        
        if DateManager.isSameWeek(previousDate, currentDate) {
            calendar.reloadData()
        } else {
            moveToPage(dateComponents: datePair.1, animated: true)
        }
    }
    
    private func moveToFoucsDate(_ date: DateComponents) {
        guard let focusDate = DateManager.convertDate(date) else { return }
        calendar.select(focusDate, scrollToDate: false)
        moveToPage(dateComponents: date, animated: false)
        calendar.reloadData()
    }
}

// MARK: - Helper
extension CalendarViewController {
    /// previousDate와 currentDate가 다른지 확인
    private func areDatesDistinct(previousDate: DateComponents, currentDate: DateComponents) -> Bool {
        guard let previousDate = currentCalendar.date(from: previousDate),
              let currentDate = currentCalendar.date(from: currentDate) else { return false }
        
        return previousDate != currentDate
    }
    
    /// 현재 캘린더 뷰에서 선택된 날짜가 있는지 체크
    private func hasSelectedDateInCurrentView() -> Bool {
        guard let selectedDate = calendar.selectedDate else { return false }
        let activeDates = activeDates()
        return activeDates.contains { $0 == selectedDate }
    }
    
    /// 현재 달력에서 Active 상태인 [Date] 가져오기
    private func activeDates() -> [Date] {
        return calendar.visibleCells().compactMap { cell in
            calendar.date(for: cell).flatMap { date in
                return calendar.cell(for: date, at: .current) != nil ? date : nil
            }
        }
    }
    
    /// 현재 달력에 표시된 모든 Date 가져오기
    private func currentPageDates() -> [Date] {
        return calendar.visibleCells()
            .compactMap { calendar.date(for: $0) }
    }
    
    /// 선택된 날짜 Components
    private func selectedDate() -> DateComponents? {
        guard let selectedDate = calendar.selectedDate else { return nil }
        let components = currentCalendar.dateComponents([.year, .month, .day], from: selectedDate)
        return components
    }
    
    /// 현재 페이지에서 첫번째 이벤트
    private func currentPageFirstEventDateComponents() -> DateComponents? {
        let currentPageDetes = currentPageDates()
            .map { DateManager.convertDateComponents($0) }
        
        let currentEvents = eventDateComponents.filter { event in
            currentPageDetes.contains { $0 == event }
        }
        return currentEvents.first
    }
    
    /// 현재 달력의 첫번째 날짜
    private func currentPageDateComponents() -> DateComponents {
        let components = currentCalendar.dateComponents([.year, .month, .day], from: calendar.currentPage)
        return components
    }
}




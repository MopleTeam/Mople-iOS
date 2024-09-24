//
//  CalendarViewController.swift
//  Group
//
//  Created by CatSlave on 9/13/24.
//

import UIKit
import RxSwift
import RxCocoa
import FSCalendar

enum ScopeType {
    case week
    case month
}

final class CalendarViewController: UIViewController {
        
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private var isWeekView: Bool = false
    private var selectedDate: Date?
    
    private let currentCalendar = DateManager.calendar
    private let todayComponents: DateComponents
    private var eventDateComponents: [DateComponents] = []
    
    // MARK: - Observable
    
    // Output
    private let heightObservable: AnyObserver<CGFloat>
    private let scopeObservable: AnyObserver<ScopeType>
    
    // Input
    private let scopeChangeObservable: Observable<Void>
    private let eventObservable: Observable<[DateComponents]>
    
    // Input/Output
    private let dateObservable: BehaviorRelay<DateComponents>
    
    // MARK: - UI Components
    private let calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.scrollDirection = .horizontal
        calendar.adjustsBoundingRectWhenChangingMonths = true
        calendar.placeholderType = .fillHeadTail
        calendar.headerHeight = 0
        calendar.rowHeight = 60
        calendar.collectionViewLayout.sectionInsets = .init(top: 5, left: 24, bottom: 5, right: 24)
        return calendar
    }()
    
    private let weekContainerView = UIView()
    
    // MARK: - LifeCycle
    init(todayComponents: DateComponents,
         heightObservable: AnyObserver<CGFloat>,
         scopeObservable: AnyObserver<ScopeType>,
         scopeChangeObservable: Observable<Void>,
         eventObservable: Observable<[DateComponents]>,
         dateObservable: BehaviorRelay<DateComponents>) {

        self.todayComponents = todayComponents
        
        self.heightObservable = heightObservable
        self.scopeObservable = scopeObservable
        
        self.scopeChangeObservable = scopeChangeObservable
        self.eventObservable = eventObservable
        
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
        
        eventObservable
            .do(onNext: { print("eventObservable : \($0.count)") })
            .subscribe(with: self, onNext: { vc, events in
                vc.updateEvents(with: events)
            })
            .disposed(by: disposeBag)
        
        dateObservable
            .skip(1)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, dateComponents in
                vc.moveToSelectedDate(dateComponents: dateComponents)
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
        let date = currentCalendar.date(from: components) ?? Date()
        return currentCalendar.date(byAdding: .year, value: -10, to: date) ?? Date()
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        var components = todayComponents
        components.month = 12
        components.day = 31
        let date = currentCalendar.date(from: components) ?? Date()
        return currentCalendar.date(byAdding: .year, value: 10, to: date) ?? Date()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let changeDate = calendar.currentPage
        let updateComponents = currentCalendar.dateComponents([.year, .month, .day], from: changeDate)
        
        dateObservable.accept(updateComponents)
    }
    
    // 셀 선택 시
    // week 일 때 선택 한다면 옵져버로 신호 보내서 헤더 이름 바꾸기
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        changeMonth(date: date, with: monthPosition)
        updateCell(date, isSelected: true)
    }
    
    // 셀 선택 해제
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateCell(date, isSelected: false)
    }
    
    // 캘린더 크기 변경 발생 시 실행
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        let maxHeight = calendar.rowHeight * 6
        let currentScope: ScopeType = calendar.scope == .month ? .month : .week
        let resultHeight = calendar.scope == .month ? maxHeight : bounds.height
        
        self.scopeObservable.onNext(currentScope)
        self.heightObservable.onNext(resultHeight)
    }
}

// MARK: - 셀 선택 시 뷰 변경
extension CalendarViewController {
    private func changeMonth(date: Date, with monthPosition: FSCalendarMonthPosition) {
        guard calendar.scope == .month else { return }
        switch monthPosition {
        case .current:
            switchScope()
        case .next, .previous:
            let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: date)
            self.moveToSelectedDate(dateComponents: dateComponents, animated: true)
        default:
            break
        }
    }
}

// MARK: - 스코프 업데이트
extension CalendarViewController {
    
    /// 스코프 변경
    private func switchScope() {
        setScope()
        updateIsWeekViewFlag(scope: calendar.scope)
        updateWhenMonthScope()
    }
    
    /// 스코프 셋팅
    private func setScope() {
        let changeScope: FSCalendarScope = self.calendar.scope == .month ? .week : .month
        calendar.setScope(changeScope, animated: true)
    }
    
    /// 현재 Scope 상태를 Boolean로 저장
    private func updateIsWeekViewFlag(scope: FSCalendarScope) {
        isWeekView = scope == .week
    }
    
    /// 주간에서 월간으로 변경될 때 표시할 값 계산
    private func updateWhenMonthScope() {
        guard calendar.scope == .month else { return }
        dateObservable.accept(getDisplayableDateComponents())
    }
    
    /// 화면에 표시할 날짜 필터링
    private func getDisplayableDateComponents() -> DateComponents {
        let activeDates = calendar.visibleCells().compactMap { cell in
            calendar.date(for: cell).flatMap { date in
                return calendar.cell(for: date, at: .current) != nil ? date : nil
            }
        }
        let currentDate = activeDates.contains { $0 == selectedDate } ? selectedDate! : calendar.currentPage
        return currentCalendar.dateComponents([.year, .month, .day], from: currentDate)
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
        return selectedDate == date
    }
    
    /// 선택된 셀이 오늘인지 확인
    /// - Parameter date: 선택된 날짜
    private func checkToday(_ date: Date) -> Bool {
        let targetComponents = currentCalendar.dateComponents([.year, .month, .day], from: date)
        
        return targetComponents == todayComponents
    }
}

// MARK: - 특정 달로 이동
extension CalendarViewController {
    private func moveToSelectedDate(dateComponents: DateComponents, animated: Bool = false) {
        
        if let date = currentCalendar.date(from: dateComponents) {
            self.calendar.setCurrentPage(date, animated: animated)
        }
    }
}


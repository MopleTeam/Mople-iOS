//
//  CalendarViewController.swift
//  Group
//
//  Created by CatSlave on 9/13/24.
//

import UIKit
import RxSwift
import FSCalendar

private enum MonthType: Int {
    case fourWeekMonth = 4
    case fiveWeekMonth = 5
    case sixWeekMonth = 6
}

final class CalendarViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private var monthType: MonthType = .fiveWeekMonth
    private var isWeekView: Bool = false
    private var selectedDate: Date?
    
    private let currentCalendar = Calendar.current
    private lazy var today: Date = self.currentCalendar.startOfDay(for: Date())
    
    lazy var calendarMaxHeight = calendar.weekdayHeight + (calendar.rowHeight * 6)
    
    // MARK: - Observable
    var heightObservable: BehaviorSubject<CGFloat> = .init(value: 0)
    
    // MARK: - UI Components
    let calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.scrollDirection = .horizontal
        calendar.adjustsBoundingRectWhenChangingMonths = true
        calendar.placeholderType = .fillHeadTail
        calendar.headerHeight = 0
        calendar.rowHeight = 60
        calendar.collectionViewLayout.sectionInsets = .init(top: 5, left: 24, bottom: 5, right: 24)
        return calendar
    }()
    
    lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    private let herderContainerView = UIView()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setCalendar()
        setupUI()
        setObservable()
        
        
    }
    

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMonthType()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = AppDesign.defaultWihte
        self.view.addSubview(calendar)
        calendar.addSubview(herderContainerView)
        herderContainerView.addSubview(calendar.calendarWeekdayView)
        
        calendar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(calendarMaxHeight)
        }
        
        herderContainerView.snp.makeConstraints { make in
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
    
    // MARK: - Set Observable
    private func setObservable() {
        setHeightObserver()
    }
    
    private func setHeightObserver() {
        self.heightObservable
            .skip(1)
            .asDriver(onErrorJustReturn: calendarMaxHeight)
            .drive(with: self, onNext: { vc, height in
                vc.updateCalendar(height)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Selectors
}

// MARK: - DataSource
extension CalendarViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "CustomCell", for: date, at: position) as! CustomCalendarCell
        
        print("셀 다시 그립니다.")
        cell.updateCell(containsEvent: true,
                        isSelected: checkSelected(date),
                        isToday: checkToday(date))
        return cell
    }
}

// MARK: - Delegate
extension CalendarViewController: FSCalendarDelegate {
    
    // 셀 선택 시
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if let selectedDate = selectedDate {
            updateCell(selectedDate, isSelected: false)
        }
        updateCell(date, isSelected: true)
        self.selectedDate = date
    }
    
    // 캘린더 크기 변경 발생 시 실행
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        heightObservable.onNext(changeHeight(bounds.height))
        
        self.view.layoutIfNeeded()
    }
}

// MARK: - 주간, 월간 전환 시 높이 조정
extension CalendarViewController {
    
    /// 캘린더 높이 변경하기
    /// - Parameter height: 변경 높이
    private func updateCalendar(_ height: CGFloat) {
        calendar.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
    }
    
    /// 주간 뷰에서 월간 뷰로 변경 시 높이 조절하기
    /// - Parameter height: FSCalendar 조정 높이
    /// - Returns: Custom 조정 높이
    private func changeHeight(_ height: CGFloat) -> CGFloat {
        guard isWeekView else { return height }
        
        // viewType 초기화
        isWeekView = false
        
        return heightOfMonthType()
    }
    
    /// 주 갯수에 따라서 높이 변경
    private func heightOfMonthType() -> CGFloat {
        let rowHeight = calendar.rowHeight
        switch monthType {
        case .fourWeekMonth:
            return rowHeight * CGFloat(monthType.rawValue) + 10
        case .fiveWeekMonth:
            return rowHeight * CGFloat(monthType.rawValue) + 5
        case .sixWeekMonth:
            return rowHeight * CGFloat(monthType.rawValue)
        }
    }
}

// MARK: - 달력 상태 업데이트
extension CalendarViewController {
    /// 현재 Scope 상태를 Boolean로 저장
    private func updateIsWeekViewFlag(scope: FSCalendarScope) {
        isWeekView = scope == .month ? false : true
    }
    
    /// 주간 달력인 경우에는 저장하지 않기 위해 scope가 month인 경우에만 monthType 업데이트
    private func updateMonthType() {
        if calendar.scope == .month {
            let calendarHeight = calendar.frame.height
            monthType = filterMonthType(height: calendarHeight)
        }
    }
    
    /// 현재 달력의 높이에 따라서 6주 or 5주로 변경
    /// - Parameters:
    ///   - height: 현재 달력의 높이
    ///   - tolerance: 오차 범위
    private func filterMonthType(height: CGFloat, tolerance: CGFloat = 20) -> MonthType {
        let currentHeight = height + tolerance // 현재 높이
        
        let sixWeekMonthHeight = calendar.rowHeight * 6
        let fiveWeeMonthkHeight = calendar.rowHeight * 5
        
        switch currentHeight {
        case ..<fiveWeeMonthkHeight:
            return .fourWeekMonth
        case ..<sixWeekMonthHeight:
            return .fiveWeekMonth
        default:
            return .sixWeekMonth
        }
    }
}

// MARK: - 셀 업데이트
extension CalendarViewController {
    /// 선택 여부에 따라서 셀 컬러 변경
    /// - Parameters:
    ///   - date: 선택된 날짜
    ///   - isSelected: 선택된 셀 or 선택됐던 셀
    private func updateCell(_ date: Date, isSelected: Bool) {
        guard let cell = calendar.cell(for: date, at: .current) as? CustomCalendarCell else { return }
        cell.updateCell(containsEvent: true, isSelected: isSelected, isToday: checkToday(date))
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
        
        let todayComponents = currentCalendar.dateComponents([.year, .month, .day], from: today)
        
        return targetComponents == todayComponents
    }
}

// MARK: - 특정 달로 이동하기
extension CalendarViewController {
    private func moveToSpecificYearMonth(year: Int, month: Int) {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1 // 해당 월의 1일로 설정
        
        if let date = currentCalendar.date(from: dateComponents) {
            self.calendar.setCurrentPage(date, animated: false)
        }
    }
}

// MARK: - 외부 사용 액션
extension CalendarViewController {
    func changeScope() {
        let changeScope: FSCalendarScope = self.calendar.scope == .month ? .week : .month
        updateIsWeekViewFlag(scope: calendar.scope)
        calendar.setScope(changeScope, animated: true)
    }
}





#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13, *)
struct CalendarViewController_Preview: PreviewProvider {
    static var previews: some View {
        CalendarAndEventsViewController(title: "일정관리").showPreview()
    }
}
#endif

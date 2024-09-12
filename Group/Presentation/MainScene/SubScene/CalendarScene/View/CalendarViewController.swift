//
//  CalendarViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import SnapKit
import FSCalendar
import RxSwift
import RxCocoa

private enum MonthType: Int {
    case fourWeekMonth = 4
    case fiveWeekMonth = 5
    case sixWeekMonth = 6
}

final class CalendarViewController: BaseViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    private var monthType: MonthType = .fiveWeekMonth
    private var isWeekView: Bool = false
    
    // MARK: - Test
    var scope: FSCalendarScope {
        return self.calendar.scope == .month ? .week : .month
    }
    
    private let testBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("테스트", for: .normal)
        btn.backgroundColor = .green
        return btn
    }()
    
    private let currentCalendar = Calendar.current
    
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private lazy var today: Date = self.currentCalendar.startOfDay(for: Date())
    
    private var selectedDate: Date?
    
    var disposeBag = DisposeBag()
    
    private let calendar = FSCalendar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCalendar()
        setupUI()
        setAction()
    }
    
    private let containerView = UIView()
    
    private func setupUI() {
        self.view.addSubview(calendar)
        self.view.addSubview(emptyView)
        self.view.addSubview(testBtn)
        calendar.addSubview(containerView)
        containerView.addSubview(calendar.calendarWeekdayView)
        
        let calendarHeight = calendar.weekdayHeight + (calendar.rowHeight * 6)
        
        calendar.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(calendarHeight)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(36)
        }
        
        calendar.calendarWeekdayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        calendar.collectionViewLayout.sectionInsets = .init(top: 5, left: 24, bottom: 5, right: 24)
                
        testBtn.snp.makeConstraints { make in
            make.center.equalTo(emptyView)
            make.size.equalTo(100)
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        self.view.clipsToBounds = false
        
        calendar.headerHeight = 0
        calendar.rowHeight = 60

        calendar.scrollDirection = .horizontal
        
        calendar.adjustsBoundingRectWhenChangingMonths = true
        
        calendar.appearance.weekdayTextColor = UIColor(hexCode: "999999")
        
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = .clear
        calendar.placeholderType = .fillHeadTail
        calendar.appearance.titleWeekendColor = .systemRed
        
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "CustomCell")
    }

    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        
    }

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "CustomCell", for: date, at: position) as! CustomCalendarCell
        
        cell.updateCell(containsEvent: true,
                        isSelected: checkSelected(date),
                        isToday: checkToday(date))
        return cell
    }

    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        
        let height = changeHeight(bounds.height)
                
        calendar.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        self.view.layoutIfNeeded()
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
    
    /// isWeekView와 scope 동기화
    private func updateIsWeekViewFlag(scope: FSCalendarScope) {
        isWeekView = scope == .month ? false : true
    }
    
    /// 주간 달력인 경우에는 저장하지 않기 위해 scope가 month인 경우에만 monthType 업데이트
    private func updateWeekType() {
        if calendar.scope == .month {
            let calendarHeight = calendar.frame.height
            monthType = updateMonthType(height: calendarHeight)
        }
    }
    
    /// 현재 달력의 높이에 따라서 6주 or 5주로 변경
    /// - Parameters:
    ///   - height: 현재 달력의 높이
    ///   - tolerance: 오차 범위
    private func updateMonthType(height: CGFloat, tolerance: CGFloat = 20) -> MonthType {
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

    // 캘린더 현재 높이 저장
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateWeekType()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if let selectedDate = selectedDate {
            updateCell(selectedDate, isSelected: false)
        }
        updateCell(date, isSelected: true)
        self.selectedDate = date
    }
    
    private func checkSelected(_ date: Date) -> Bool {
        return selectedDate == date
    }
    
    private func updateCell(_ date: Date, isSelected: Bool) {
        guard let cell = calendar.cell(for: date, at: .current) as? CustomCalendarCell else { return }
        cell.updateCell(containsEvent: true, isSelected: isSelected, isToday: checkToday(date))
    }
    
    private func checkToday(_ date: Date) -> Bool {
        let targetComponents = currentCalendar.dateComponents([.year, .month, .day], from: date)
        
        let todayComponents = currentCalendar.dateComponents([.year, .month, .day], from: today)
        
        return targetComponents == todayComponents
    }
    
    private func setAction() {
        self.testBtn.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.updateIsWeekViewFlag(scope: vc.calendar.scope)
                vc.calendar.setScope(vc.scope, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func moveToSpecificYearMonth(year: Int, month: Int) {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1 // 해당 월의 1일로 설정

        if let date = calendar.date(from: dateComponents) {
            self.calendar.setCurrentPage(date, animated: true)
        }
    }
}

class CustomCalendarCell: FSCalendarCell {
    
    private var isCornerRadiusSet = false
    
    private let dotContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    private let eventDot: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    private let indicatorView = UIView()
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupTitleLabel()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !isCornerRadiusSet {
            indicatorView.layer.cornerRadius = indicatorView.frame.height / 2
            dotContainer.layer.cornerRadius = dotContainer.frame.height / 2
            eventDot.layer.cornerRadius = eventDot.frame.height / 2
            isCornerRadiusSet = true
        }
    }
    
    private func setupViews() {
        contentView.addSubview(indicatorView)
        indicatorView.addSubview(dotContainer)
        dotContainer.addSubview(eventDot)
        
        indicatorView.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.center.equalTo(titleLabel)
        }
        
        dotContainer.snp.makeConstraints { make in
            make.size.equalTo(12)
            make.bottom.trailing.equalToSuperview()
        }
        
        eventDot.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
        
    }
    
    func setupTitleLabel() {
        titleLabel.layer.zPosition = 1
    }
    
    func updateCell(containsEvent: Bool,
                    isSelected: Bool,
                    isToday: Bool) {
        
        dotContainer.isHidden = !containsEvent
        
        guard !isSelected else {
            indicatorView.backgroundColor = .init(hexCode: "3366FF").withAlphaComponent(0.1)
            return
        }
        
        indicatorView.backgroundColor = isToday ? .init(hexCode: "F4F5F6") : .clear
    }
}





#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13, *)
struct CalendarViewController_Preview: PreviewProvider {
    static var previews: some View {
        CalendarViewController(title: "일정관리").showPreview()
    }
}
#endif




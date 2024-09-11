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

final class CalendarViewController: BaseViewController, FSCalendarDelegate, FSCalendarDataSource {
    
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
    
    private func setupUI() {
        self.view.addSubview(calendar)
        self.view.addSubview(testBtn)
        
        let calendarHeight = calendar.weekdayHeight + (calendar.rowHeight * 5)
        
        calendar.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(calendarHeight)
        }
        
        testBtn.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom)
            make.trailing.equalTo(calendar.snp.trailing)
            make.size.equalTo(40)
        }
        
        testBtn.layer.cornerRadius = 20
    }
    
    private func setCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        
        calendar.headerHeight = 0
        calendar.weekdayHeight = 36
        calendar.rowHeight = 56
        
        calendar.scrollDirection = .horizontal
        
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
        calendar.snp.updateConstraints { (make) in
            make.height.equalTo(bounds.height)
        }
        self.view.layoutIfNeeded()
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
                vc.calendar.setScope(self.scope, animated: true)
            })
            .disposed(by: disposeBag)
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



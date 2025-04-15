//
//  PlanDatePickerView.swift
//  Mople
//
//  Created by CatSlave on 12/6/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class DateSelectViewController: BaseViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = CreatePlanViewReactor
    private var createPlanReactor: CreatePlanViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private let today = Date()
    private let todayComponents = DateManager.todayComponents
    private var selectedDate: DateComponents = DateManager.todayComponents
    private var years: [Int] = []
    private var months: [Int] = []
    private var dates: [Int] = []
    
    // MARK: - UI Components
    private let pickerView = CustomPickerView(title: TextStyle.CreatePlan.Picker.date)
    
    // MARK: - LifeCycle
    init(reactor: CreatePlanViewReactor?) {
        super.init()
        self.createPlanReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        setupUI()
        setPresentationStyle()
        setReactor()
        setAction()
    }
    
    // MARK: - ModalStyle
    private func setPresentationStyle() {
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [ .medium() ]
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setupPickerview()
    }
    
    private func setLayout() {
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupPickerview() {
        self.pickerView.setDelegate(delegate: self)
        self.defaultDateSeting()
    }
    
    // MARK: - Action
    private func setAction() {
        self.pickerView.sheetView.rx.closeEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Setup
extension DateSelectViewController {
    private func setReactor() {
        reactor = createPlanReactor
    }
    
    func bind(reactor: CreatePlanViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        self.pickerView.sheetView.rx.completedEvent
            .asDriver()
            .compactMap({ [weak self] _ in
                self?.selectedDate
            })
            .drive(with: self, onNext: { vc, date in
                reactor.action.onNext(.setValue(.date(date, type: .day)))
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        reactor.pulse(\.$selectedDay)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, selectedDate in
                vc.selectedDate = selectedDate
                vc.moveToYearComponents()
            })
            .disposed(by: disposeBag)
    }
}

extension DateSelectViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: years.count
        case 1: months.count
        case 2: dates.count
        default: 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        let label = self.pickerView.dequeuePickerLabel(reusing: view)
        
        switch component {
        case 0: label.text = "\(years[row]) 년"
        case 1: label.text = "\(months[row]) 월"
        case 2: label.text = "\(dates[row]) 일"
        default: break
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            let selectedYear = years[row]
            guard selectedYear != self.selectedDate.year else { return }
            self.selectedDate.year = selectedYear
            self.moveToYearComponents()
        case 1:
            let selectedMonth = months[row]
            guard selectedMonth != self.selectedDate.month else { return }
            self.selectedDate.month = selectedMonth
            self.moveToMonthComponents()
        case 2:
            self.selectedDate.day = dates[row]
        default:
            break
        }
        
        print(#function, #line, "Path : # 1209 : \(selectedDate) ")
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}

// MARK: - 기본 날짜 값 설정
extension DateSelectViewController {

    /// date로 값으로 피커뷰 Row를 설정
    private func defaultDateSeting() {
        settingYears()
        settingMonths()
        settingDates()
    }

    /// 현재 년부터 10년뒤까지만 표시
    private func settingYears() {
        let startYear = todayComponents.year ?? 2025
        let endYear = startYear + 10
        years = Array(startYear...endYear)
    }

    /// 현재 월로부터 12월까지 표시
    private func settingMonths() {
        months = Array((todayComponents.month ?? 1)...12)
    }

    /// 현재 일로부터 마지막날까지 표시
    private func settingDates() {
        let daysCountOfMonth = DateManager.getDaysCountInCurrentMonth(on: todayComponents)
        dates = Array((todayComponents.day ?? 1)...daysCountOfMonth)
    }
}

// MARK: - Picker Update
extension DateSelectViewController {
    
    enum ReloadRange {
        case month
        case day
    }
    
    /// 범위에 맞춰서 피커뷰 리로드
    private func reloadComponents(range: ReloadRange) {
        if case range = .month {
            self.pickerView.reloadComponent(1)
        }
        self.pickerView.reloadComponent(2)
        selectDate()
    }
    
    /// 로우 업데이트
    private func setRow(yearIndex: Int, monthIndex: Int, dayIndex: Int) {
        self.pickerView.selectRow(row: yearIndex, inComponent: 0, animated: false)
        self.pickerView.selectRow(row: monthIndex, inComponent: 1, animated: false)
        self.pickerView.selectRow(row: dayIndex, inComponent: 2, animated: false)
    }
    
    /// 년도 피커뷰 조작 시 날짜 유효성을 거친 후 업데이트
    private func moveToYearComponents() {
        let isFuture = self.isValidFutureDate()
        updateSelectedDay()
        updateMonth(isFuture: isFuture)
        reloadComponents(range: .month)
    }
    
    /// 월 피커뷰 조작 시 날짜 유효성을 거친 후 업데이트
    private func moveToMonthComponents() {
        let isFuture = self.isValidFutureDate()
        updateSelectedDay()
        updateDay(isFuture: isFuture)
        reloadComponents(range: .day)
    }
}

// MARK: - Select Value Update
extension DateSelectViewController {
    
    /// 들어온 값이 있는 날짜인지 체크 후 Row 변경
    private func selectDate() {
        let dateIndex = getDateIndex(on: selectedDate)
        
        updateSelectedDate(yearIndex: dateIndex.year,
                        monthIndex: dateIndex.month,
                        dayIndex: dateIndex.day)
        
        setRow(yearIndex: dateIndex.year,
               monthIndex: dateIndex.month,
               dayIndex: dateIndex.day)
    }
    
    /// 들어온 값이 선택할 수 있는 값인지 체크 후 Index return
    private func getDateIndex(on dateComponents: DateComponents) -> (year: Int, month: Int, day: Int) {
        guard let year = dateComponents.year,
              let month = dateComponents.month,
              let day = dateComponents.day else { return (0, 0, 0)}
        
        let yearIndex = self.years.firstIndex(of: year) ?? 0
        let monthIndex = self.months.firstIndex(of: month) ?? 0
        let dateIndex = self.dates.firstIndex(of: day) ?? 0
        
        return (yearIndex, monthIndex, dateIndex)
    }
    
    /// Index를 받아서 업데이트
    private func updateSelectedDate(yearIndex: Int, monthIndex: Int, dayIndex: Int) {
        selectedDate.year = years[safe: yearIndex]
        selectedDate.month = months[safe: monthIndex]
        selectedDate.day = dates[safe: dayIndex]
    }
    
    /// 업데이트된 날짜에 마지막 날짜를 계산 후 selectedDate 업데이트
    private func updateSelectedDay() {
        let daysCountOfMonth = DateManager.getDaysCountInCurrentMonth(on: selectedDate)
        self.dates = Array(1...daysCountOfMonth)
        
        if !self.dates.contains(where: { $0 == self.selectedDate.day }) {
            self.selectedDate.day = self.dates.last
        }
    }
    
    /// 피커뷰에서 과거날짜는 보여주지 않기에 과거 날짜인 경우 교정 (월 기준)
    private func isValidFutureDate() -> Bool {
        let date = selectedDate.toDate() ?? today
        let months = DateManager.numberOfMonthBetween(date)
        if months < 0 {
            selectedDate.year = todayComponents.year
            selectedDate.month = todayComponents.month
        }
        return months > 0
    }
    
    /// 년도 피커 조작 시 년도 아래로 업데이트
    private func updateMonth(isFuture: Bool) {
        let isCurrentYear = todayComponents.year == selectedDate.year
        self.months = !isCurrentYear && isFuture ? Array(1...12) : Array((todayComponents.month ?? 1)...12)
        updateDay(isFuture: isFuture)
    }
    
    /// 월 피커 조작 시 월 아래로 업데이트
    private func updateDay(isFuture: Bool) {
        guard !isFuture else { return }
        dates.removeAll { $0 < self.todayComponents.day ?? 1 }
    }
}



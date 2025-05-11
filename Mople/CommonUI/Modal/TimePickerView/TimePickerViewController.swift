//
//  PlanTimePickerView.swift
//  Mople
//
//  Created by CatSlave on 12/20/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TimePickerViewController: BaseViewController {
    
    enum DayPeriod {
        case am
        case pm
        
        var localized: String {
            switch self {
            case .am: return L10n.Date.Period.am
            case .pm: return L10n.Date.Period.pm
            }
        }
    }
    
    // MARK: - Closure
    private var selected: ((DateComponents?) -> Void)?

    // MARK: - Variables
    private var disposeBag = DisposeBag()
    private var todayTime = Date().getTime()
    private let hours: [Int] = Array(0...11).map { $0 % 12 == 0 ? 12 : $0 }
    private let minutes: [Int] = Array(stride(from: 0, through: 55, by: 5))
    private let period: [DayPeriod] = [.am, .pm]
    private let virtualRows: Int = 10_000
    
    // MARK: - Selected Value
    private var selectedTime: DateComponents?
    private var selectedPeriod: DayPeriod?
    
    // MARK: - Infinite Set
    private var hoursMiddleRow: Int {
        return (virtualRows / hours.count / 2) * hours.count
    }
    private var minutesMiddleRow: Int {
        return (virtualRows / minutes.count / 2) * minutes.count
    }
    
    // MARK: - UI Components
    private let pickerView = DefaultPickerView(title: L10n.Picker.time)
    
    // MARK: - LifeCycle
    init(selectedTime: DateComponents? = nil,
         completion: ((DateComponents?) -> Void)? = nil) {
        self.selectedTime = selectedTime
        self.selected = completion
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        setupUI()
        setPresentationStyle()
        bind()
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
        setDefaultTime()
    }
    
    private func setLayout() {
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupPickerview() {
        self.pickerView.setDelegate(delegate: self)
    }
    
    private func setDefaultTime() {
        guard let defaultTime = configurePeriodSettings(on: selectedTime) else { return }
        setDefaultTime(on: defaultTime)
    }
    
    // MARK: - Action
    private func bind() {
        self.pickerView.modalView.rx.closeEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.pickerView.modalView.rx.completedEvent
            .map({ [weak self] in
                let selectedTime = self?.selectedTime
                return self?.convert24hourSelctedTime(on: selectedTime)
            })
            .subscribe(with: self, onNext: { vc, selectedTime in
                vc.selected?(selectedTime)
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension TimePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: virtualRows
        case 1: virtualRows
        case 2: period.count
        default: 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        let label = self.pickerView.dequeuePickerLabel(reusing: view)
        
        switch component {
        case 0: label.text =
            "\(hours[row % hours.count])" + " " + L10n.Date.Label.hourShort
        case 1: label.text =
            "\(minutes[row % minutes.count])" + " " + L10n.Date.Label.minute
        case 2: label.text =
            period[row].localized
        default: break
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            pickerView.selectRow(hoursMiddleRow + (row % hours.count),
                                 inComponent: 0,
                                 animated: false)
            selectedTime?.hour = hours[row % hours.count]
        case 1:
            pickerView.selectRow(minutesMiddleRow + (row % minutes.count),
                                 inComponent: 1,
                                 animated: false)
            selectedTime?.minute = minutes[row % minutes.count]
        case 2:
            selectedPeriod = period[row]
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}

// MARK: - Row 설정
extension TimePickerViewController {
    private func setDefaultTime(on date: DateComponents) {
        self.selectedTime = date
        setHourRow(on: date)
        setMinuteRow(on: date)
        setPeriodRow()
    }
    
    private func setHourRow(on date: DateComponents) {
        guard let hour = date.hour,
              let hourIndex = self.hours.firstIndex(of: hour == 0 ? 12 : hour) else { return }
        let hourRow = hoursMiddleRow + hourIndex
        self.pickerView.selectRow(row: hourRow, inComponent: 0, animated: false)
    }
    
    private func setMinuteRow(on date: DateComponents) {
        guard let minute = date.minute,
              let minuteIndex = self.minutes.firstIndex(of: minute / 5 * 5) else { return }
        let minuteRow = minutesMiddleRow + minuteIndex
        self.pickerView.selectRow(row: minuteRow, inComponent: 1, animated: false)
    }
    
    private func setPeriodRow() {
        guard let period = self.selectedPeriod,
              let periodIndex = self.period.firstIndex(of: period) else { return }
        self.pickerView.selectRow(row: periodIndex, inComponent: 2, animated: false)
    }
}

// MARK: - Helper
extension TimePickerViewController {

    /// 24시간 기준으로 변경하기
    private func convert24hourSelctedTime(on date: DateComponents?) -> DateComponents? {
        guard let date,
              let selectedPeriod else { return nil }
        switch selectedPeriod {
        case .am:
            guard let hour = self.selectedTime?.hour,
                  hour == 12 else { return date }
            return .init(hour: hour - 12, minute: date.minute)
        case .pm:
            return DateManager.convertTo24Hour(date)
        }
    }
    
    /// 오전, 오후 시간 판단 및 12시간 기준으로 변경
    private func configurePeriodSettings(on date: DateComponents?) -> DateComponents? {
        let date = date ?? addOneHourToday()
        guard let hour = date.hour else { return nil }
        self.selectedPeriod = hour >= 12 ? .pm : .am
        return DateManager.convertTo12Hour(date)
    }
    
    /// 현재 시간에서 한시간 더해진 시간
    private func addOneHourToday() -> DateComponents {
        guard let currentHour = todayTime.hour else { return todayTime }
        return .init(hour: currentHour + 1, minute: 0)
    }
}

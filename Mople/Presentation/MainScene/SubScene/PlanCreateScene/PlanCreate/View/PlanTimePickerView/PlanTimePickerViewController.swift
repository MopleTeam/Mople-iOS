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
import ReactorKit

final class PlanTimePickerViewController: UIViewController, View {
    
    enum DayPeriod: String {
        case am = "오전"
        case pm = "오후"
    }
    
    typealias Reactor = PlanCreateViewReactor
    
    // MARK: - Variables
    var disposeBag = DisposeBag()
    
    // MARK: - Default Value
    private var todayTime = Date().getTime()
    private let hours: [Int] = Array(0...11).map { $0 % 12 == 0 ? 12 : $0 }
    private let minutes: [Int] = Array(stride(from: 0, through: 55, by: 5))
    private let period: [DayPeriod] = [.am, .pm]
    
    private let virtualRows: Int = 10_000
    
    private var hoursMiddleRow: Int {
        return (virtualRows / hours.count / 2) * hours.count
    }
    
    private var minutesMiddleRow: Int {
        return (virtualRows / minutes.count / 2) * minutes.count
    }
    
    // MARK: - Selected Value
    private var selectedTime: DateComponents?
    private var selectedPeriod: DayPeriod?
    
    // MARK: - UI Components
    private let pickerView = DefaultPickerView(title: TextStyle.DatePicker.header)
    
    // MARK: - LifeCycle
    init(reactor: PlanCreateViewReactor?) {
        print(#function, #line, "LifeCycle Test CalendarDate PickerView Created" )
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test CalendarDate PickerView Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        initialSetup()
    }
    
    private func initialSetup() {
        setupUI()
        setupPickerview()
        setPresentationStyle()
        setupAction()
    }
    
    // MARK: - ModalStyle
    private func setPresentationStyle() {
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [ .medium() ]
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Default Date
    private func setupPickerview() {
        self.pickerView.setDelegate(delegate: self)
    }
    
    // MARK: - Binding
    func bind(reactor: PlanCreateViewReactor) {
        self.pickerView.sheetView.rx.completedEvent
            .asDriver()
            .compactMap({ [weak self] _ -> DateComponents? in
                guard let date = self?.selectedTime else { return nil }
                return self?.convert24hourSelctedTime(on: date)
            })
            .drive(with: self, onNext: { vc, date in
                reactor.action.onNext(.setValue(.date(date, type: .time)))
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(self.rx.viewWillAppear, reactor.pulse(\.$selectedTime))
            .take(1)
            .compactMap({ [weak self] in
                return self?.configurePeriodSettings(on: $0.1)
            })
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, time in
                vc.setCurrentTime(on: time)
                vc.setDefaultTime(on: time)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action
    private func setupAction() {
        self.pickerView.sheetView.rx.closeEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Delegate
extension PlanTimePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
            "\(hours[row % hours.count]) 시"
        case 1: label.text =
            "\(minutes[row % minutes.count])분"
        case 2: label.text = 
            "\(period[row].rawValue)"
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
extension PlanTimePickerViewController {
    private func setCurrentTime(on date: DateComponents?) {
        setHourRow(on: date)
        setMinuteRow(on: date)
        setPeriodRow()
    }
    
    private func setHourRow(on date: DateComponents?) {
        guard let hour = date?.hour,
              let hourIndex = self.hours.firstIndex(of: hour == 0 ? 12 : hour) else { return }
        let hourRow = hoursMiddleRow + hourIndex
        self.pickerView.selectRow(row: hourRow, inComponent: 0, animated: false)
    }
    
    private func setMinuteRow(on date: DateComponents?) {
        guard let minute = date?.minute,
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

// MARK: - Hleper
extension PlanTimePickerViewController {
    
    /// 선택값 기본설정
    private func setDefaultTime(on date: DateComponents?) {
        self.selectedTime = .init(hour: date?.hour,
                                  minute: date?.minute)
    }

    /// 24시간 기준으로 변경하기
    private func convert24hourSelctedTime(on date: DateComponents) -> DateComponents {
        guard let selectedPeriod else { return date }
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

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
    private let todayTime = DateManager.today.getTime()
    private let hours: [Int] = Array(0...11).map { $0 % 12 == 0 ? 12 : $0 }
    private let minutes: [Int] = Array(stride(from: 0, through: 55, by: 5))
    private let period: [DayPeriod] = [.am, .pm]
    
    // MARK: - Selected Value
    private var selectedTime: DateComponents?
    private var selectedPeriod: DayPeriod?
    
    // MARK: - UI Components
    private let pickerView = DefaultPickerView(title: TextStyle.DatePicker.header)
    
    // MARK: - LifeCycle
    init(reactor: PlanCreateViewReactor) {
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
        self.pickerView.completedButtonTap
            .asDriver()
            .compactMap({ [weak self] _ -> DateComponents? in
                guard let date = self?.selectedTime else { return nil }
                return self?.convert24hourSelctedTime(on: date)
            })
            .drive(with: self, onNext: { vc, date in
                print(#function, #line, "#9 : \(date)" )
                reactor.action.onNext(.setPlanDate(date: date, type: .time))
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
        self.pickerView.closeButtonTap
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
        case 0: hours.count
        case 1: minutes.count
        case 2: period.count
        default: 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        let label = self.pickerView.dequeuePickerLabel(reusing: view)
        
        switch component {
        case 0: label.text = "\(hours[row]) 시"
        case 1: label.text = "\(minutes[row]) 분"
        case 2: label.text = "\(period[row].rawValue)"
        default: break
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: selectedTime?.hour = hours[row]
        case 1: selectedTime?.minute = minutes[row]
        case 2: selectedPeriod = period[row]
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}

// MARK: - Hleper
extension PlanTimePickerViewController {
    
    /// 선택값 기본설정
    private func setDefaultTime(on date: DateComponents?) {
        guard let hour = date?.hour,
              let minute = date?.minute else { return }
        self.selectedTime = .init(hour: hour, minute: minute)
    }
    
    /// Row 설정
    private func setCurrentTime(on date: DateComponents?) {
        guard let hour = date?.hour,
              let minute = date?.minute,
              let period = self.selectedPeriod,
              let hourIndex = self.hours.firstIndex(of: hour == 0 ? 12 : hour),
              let minuteIndex = self.minutes.firstIndex(of: (minute / 5) * 5),
              let periodIndex = self.period.firstIndex(of: period) else { return }
        
        [hourIndex, minuteIndex, periodIndex].enumerated().forEach { (components, index) in
            self.pickerView.selectRow(row: index, inComponent: components, animated: false)
        }
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
        let date = date ?? todayTime
        guard let hour = date.hour else { return nil }
        self.selectedPeriod = hour >= 12 ? .pm : .am
        return DateManager.convertTo12Hour(date)
    }
}

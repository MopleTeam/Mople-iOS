//
//  BaseDatePickViewController.swift
//  Group
//
//  Created by CatSlave on 9/19/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class YearMonthPickerViewController: BaseViewController, View {
    
    typealias Reactor = CalendarViewReactor
    
    // MARK: - Variables
    var disposeBag: DisposeBag = DisposeBag()
    
    private let todayComponents = DateManager.todayComponents
    private lazy var selectedDate = todayComponents
    
    private lazy var years: [Int] = {
        let currentYear = todayComponents.year ?? 2024
        let startYear = currentYear - 10
        let endYear = currentYear + 10
        return Array(startYear...endYear)
    }()
    
    private let months: [Int] = Array(1...12)
    
    // MARK: - Observable
    private let selectedDateObserver: PublishRelay<DateComponents> = .init()
    
    // MARK: - UI Components
    private let pickerView = DefaultPickerView(title: TextStyle.DatePicker.header)
    
    // MARK: - LifeCycle
    init(reactor: Reactor? = nil) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        setupUI()
        setupAction()
        setPickerView()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setPickerView() {
        self.pickerView.setDelegate(delegate: self)
    }
    
    // MARK: - Bind
    func bind(reactor: CalendarViewReactor) {
        selectedDateObserver
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.requestPageSwitch(dateComponents: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(self.rx.viewWillAppear, reactor.pulse(\.$changedPage))
            .map({ $0.1 })
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, dateComponents in
                vc.defaultSelectedDate(on: dateComponents)
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
        
        self.pickerView.sheetView.rx.completedEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                let selectedDate = vc.selectedDate
                vc.selectedDateObserver.accept(selectedDate)
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Delegate
extension YearMonthPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: years.count
        case 1: months.count
        default: 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        let label = self.pickerView.dequeuePickerLabel(reusing: view)
        
        switch component {
        case 0: label.text = "\(years[row]) 년"
        case 1: label.text = "\(months[row]) 월"
        default: break
        }
                
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0: selectedDate.year = years[row]
        case 1: selectedDate.month = months[row]
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}

// MARK: - Input Date
extension YearMonthPickerViewController {
    private func defaultSelectedDate(on dateComponents: DateComponents? = nil) {
        if let dateComponents {
            self.selectDate(dateComponents)
        } else {
            self.selectDate(todayComponents)
        }
    }
    
    private func selectDate(_ dateComponents: DateComponents) {
        guard let year = dateComponents.year,
              let month = dateComponents.month else { return }
        
        let yearIndex = self.years.firstIndex(of: year) ?? 2025
        let monthIndex = self.months.firstIndex(of: month) ?? 1
        
        self.pickerView.selectRow(row: yearIndex, inComponent: 0, animated: false)
        self.pickerView.selectRow(row: monthIndex, inComponent: 1, animated: false)
    }
}

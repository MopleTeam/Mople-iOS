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

final class YearMonthPickerViewController: UIViewController, View {
    
    typealias Reactor = CalendarViewReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Observable
    private let selectedDateObserver: PublishRelay<DateComponents> = .init()
    
    // MARK: - Variables
    private let today = DateManager.today.getComponents()
    private lazy var selectedDate: DateComponents = today
    
    private lazy var years: [Int] = {
        let currentYear = today.year ?? 2024
        
        let startYear = currentYear - 10
        let endYear = currentYear + 10
        return Array(startYear...endYear)
    }()
    
    private var months: [Int] = Array(1...12)
    
    // MARK: - UI Components
    private let pickerView = DefaultPickerView(title: TextStyle.DatePicker.header)
    
    // MARK: - LifeCycle
    init(reactor: Reactor? = nil) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        setupUI()
        setupAction()
        setDatePicker()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
    }
    
    private func setLayout() {
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setDatePicker() {
        pickerView.setDelegate(delegate: self)
        setSelectRow(date: selectedDate)
    }
    
    private func dequeuePickerLabel(reusing view: UIView?) -> UILabel {
        return (view as? UILabel) ?? {
            let newLabel = UILabel()
            newLabel.textAlignment = .center
            newLabel.textColor = .black
            newLabel.font = FontStyle.Title2.semiBold
            return newLabel
        }()
    }
    
    // MARK: - Bind
    func bind(reactor: CalendarViewReactor) {
        selectedDateObserver
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.requestPageSwitch(dateComponents: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$changedPage)
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, date in
                vc.selectedDate = date
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action
    private func setupAction() {
        self.pickerView.closeButtonTap
            .subscribe(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.pickerView.completedButtonTap
            .map({ _ in self.selectedDate })
            .subscribe(with: self, onNext: { vc, date in
                vc.selectedDateObserver.accept(date)
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Select Row
extension YearMonthPickerViewController {
    private func setSelectRow(date: DateComponents) {
        guard let year = date.year,
              let month = date.month else { return }
        
        let monthIndex = months.firstIndex(of: month) ?? 0
        let yearIndex = years.firstIndex(of: year) ?? 0
        
        pickerView.selectRow(row: monthIndex, inComponent: 0, animated: false)
        pickerView.selectRow(row: yearIndex, inComponent: 1, animated: false)
    }
}

// MARK: - DatePicker
extension YearMonthPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: months.count
        case 1: years.count
        default: 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        let label = self.dequeuePickerLabel(reusing: view)
        
        switch component {
        case 0: label.text = "\(months[row]) 월"
        case 1: label.text = "\(years[row]) 년"
        default: break
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            selectedDate.month = months[row]
        } else {
            selectedDate.year = years[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}


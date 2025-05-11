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

final class YearMonthPickerViewController: BaseViewController {
    
    // MARK: - Closure
    var completed: ((DateComponents) -> Void)?
        
    // MARK: - Variables
    private var disposeBag: DisposeBag = DisposeBag()
    private let todayComponents = DateManager.todayComponents
    private var selectedDate: DateComponents
    private lazy var years: [Int] = {
        let currentYear = todayComponents.year ?? 2024
        let startYear = currentYear - 10
        let endYear = currentYear + 10
        return Array(startYear...endYear)
    }()
    
    private let months: [Int] = Array(1...12)

    // MARK: - UI Components
    private let pickerView = DefaultPickerView(title: L10n.Picker.date)
    
    // MARK: - LifeCycle
    init(defaultDate: DateComponents) {
        self.selectedDate = defaultDate
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        setupUI()
        setupAction()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setPickerView()
    }
    
    private func setLayout() {
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setPickerView() {
        pickerView.setDelegate(delegate: self)
        setDefaultDate()
    }
    
    // MARK: - Action
    private func setupAction() {
        self.pickerView.modalView.rx.closeEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.pickerView.modalView.rx.completedEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.completed?(vc.selectedDate)
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
        case 0: label.text = "\(years[row])" + " " + L10n.Date.Label.year
        case 1: label.text = "\(months[row])" + " " + L10n.Date.Label.monthShort
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
    private func setDefaultDate() {
        guard let year = selectedDate.year,
              let month = selectedDate.month else { return }
        
        let yearIndex = self.years.firstIndex(of: year) ?? 2025
        let monthIndex = self.months.firstIndex(of: month) ?? 1
        
        self.pickerView.selectRow(row: yearIndex, inComponent: 0, animated: false)
        self.pickerView.selectRow(row: monthIndex, inComponent: 1, animated: false)
    }
}

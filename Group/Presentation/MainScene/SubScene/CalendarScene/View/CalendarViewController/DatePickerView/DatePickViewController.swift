//
//  BaseDatePickViewController.swift
//  Group
//
//  Created by CatSlave on 9/19/24.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

final class DatePickViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Observable
    private let dateObservable: BehaviorRelay<DateComponents>
    
    // MARK: - Variables
    private let todayComponents: DateComponents
    private lazy var selectedDate: DateComponents = todayComponents
    
    private lazy var currentYear: Int = {
        todayComponents.year ?? 2024
    }()
    
    private lazy var years: [Int] = {
        let startYear = currentYear - 10
        let endYear = currentYear + 10
        return Array(startYear...endYear)
    }()
    
    private var months: [Int] = Array(1...12)
    
    // MARK: - UI Components
    private let navigationView = CustomNavigationBar()
    
    private let rightBarButton: UIButton = {
        let button = UIButton()
        button.setImage(AppDesign.DatePicker.closeImage, for: .normal)
        return button
    }()
    
    private let datePicker = UIPickerView()
    
    private let completeButton: BaseButton = {
        let btn = BaseButton(backColor: AppDesign.DatePicker.completeButtonColor,
                             radius: 8,
                             configure: AppDesign.DatePicker.pickerComplete)
        return btn
    }()
            
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [navigationView, datePicker, completeButton])
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.distribution = .fill
        sv.layer.cornerRadius = 8
        sv.backgroundColor = AppDesign.defaultWihte
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 20, bottom: 28, right: 20)
        return sv
    }()
    
    // MARK: - LifeCycle
    init(title: String?,
         todayComponents: DateComponents,
         dateObservable: BehaviorRelay<DateComponents>) {
        
        self.todayComponents = todayComponents
        self.dateObservable = dateObservable
        
        defer {
            setTitle(title)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setDatePicker()
        setupUI()
        setupBinding()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setNavigationView()
    }
    
    private func setLayout() {
        view.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        navigationView.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        completeButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    private func setTitle(_ title: String?) {
        navigationView.titleLable.text = title
    }
    
    private func setNavigationView() {
        navigationView.setRightItem(item: rightBarButton)
    }
    
    private func setDatePicker() {
        datePicker.dataSource = self
        datePicker.delegate = self
        
        guard let year = todayComponents.year,
              let month = todayComponents.month else { return }
        
        setSelectRow(month: month, year: year)
    }
    
    // MARK: - Bind
    private func setupBinding() {
        dateObservable
            .subscribe(with: self, onNext: { vc, date in
                vc.updateSelectRow(newDate: date)
            })
            .disposed(by: disposeBag)
        
        rightBarButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        completeButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.dateObservable.accept(vc.selectedDate)
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Select Row
extension DatePickViewController {
    private func setSelectRow(month: Int, year: Int) {
        let monthIndex = months.firstIndex(of: month) ?? 0
        let yearIndex = years.firstIndex(of: year) ?? 0
        
        datePicker.selectRow(monthIndex, inComponent: 0, animated: false)
        datePicker.selectRow(yearIndex, inComponent: 1, animated: false)
    }
    
    private func updateSelectRow(newDate: DateComponents) {
        selectedDate = newDate
        
        guard let year = newDate.year,
              let month = newDate.month else { return }

        setSelectRow(month: month, year: year)
    }
}

// MARK: - DatePicker
extension DatePickViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return months.count
        } else {
            return years.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = .pretendard(type: .bold, size: 22)
        
        if component == 0 {
            label.text = "\(months[row]) 월"
        } else {
            label.text = "\(years[row]) 년"
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


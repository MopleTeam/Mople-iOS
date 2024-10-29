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

final class DatePickViewController: UIViewController, View {
    
    typealias Reactor = CalendarViewReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Observable
    private let pageChangeRequestObserver: PublishRelay<DateComponents> = .init()
    
    // MARK: - Variables
    private lazy var today = Date().getComponents()
    private lazy var selectedDate: DateComponents = today
    
    private lazy var years: [Int] = {
        let currentYear = today.year ?? 2024
        
        let startYear = currentYear - 10
        let endYear = currentYear + 10
        return Array(startYear...endYear)
    }()
    
    private var months: [Int] = Array(1...12)
    
    // MARK: - UI Components
    private let navigationView: CustomNavigationBar = {
        let bar = CustomNavigationBar()
        bar.titleLable.text = "날짜 선택"
        return bar
    }()
    
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
        sv.layer.cornerRadius = 13
        sv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sv.backgroundColor = AppDesign.defaultWihte
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 20, bottom: 28, right: 20)
        return sv
    }()
    
    // MARK: - LifeCycle
    init(reactor: Reactor ) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setDatePicker()
        setupUI()
        setupAction()
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
    
    private func setNavigationView() {
        navigationView.setRightItem(item: rightBarButton)
    }
    
    private func setDatePicker() {
        datePicker.dataSource = self
        datePicker.delegate = self
        setSelectRow(date: selectedDate)
    }
    
    // MARK: - Bind
    func bind(reactor: CalendarViewReactor) {
        pageChangeRequestObserver
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
        rightBarButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        completeButton.rx.controlEvent(.touchUpInside)
            .map({ _ in
                self.selectedDate
            })
            .subscribe(with: self, onNext: { vc, date in
                vc.pageChangeRequestObserver.accept(date)
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Select Row
extension DatePickViewController {
    private func setSelectRow(date: DateComponents) {
        guard let year = date.year,
              let month = date.month else { return }
        
        let monthIndex = months.firstIndex(of: month) ?? 0
        let yearIndex = years.firstIndex(of: year) ?? 0
        
        datePicker.selectRow(monthIndex, inComponent: 0, animated: false)
        datePicker.selectRow(yearIndex, inComponent: 1, animated: false)
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


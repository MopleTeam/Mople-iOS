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

final class BaseDatePickViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let currentCalendar = Calendar.current
    
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
    
    private lazy var currentYear: Int = {
        currentCalendar.component(.year, from: Date())
    }()
    
    private lazy var currentMonth: Int = {
        currentCalendar.component(.month, from: Date())
    }()
    
    private lazy var years: [Int] = {
        let currentYear = currentCalendar.component(.year, from: Date())
        let startYear = currentYear - 10
        let endYear = currentYear + 10
        return Array(startYear...endYear)
    }()
    
    private var months: [Int] = Array(1...12)
    
    init(title: String?) {
        super.init(nibName: nil, bundle: nil)
        setTitle(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupDatePicker()
        setRightBarButton()
        setupBinding()
        setDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = .black.withAlphaComponent(0.6)
        }
    }
    
    private func setupDatePicker() {
        self.view.backgroundColor = .clear
        view.addSubview(mainStackView)
        
        
        mainStackView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(361)
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
    
    private func setRightBarButton() {
        navigationView.rightButtonContainerView.addSubview(rightBarButton)
        
        rightBarButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupBinding() {
        datePicker.dataSource = self
        datePicker.delegate = self
        
        rightBarButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.dismissView()
            })
            .disposed(by: disposeBag)
        
        completeButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.dismissView()
            })
            .disposed(by: disposeBag)
    }
    
    private func setDate() {
        let monthIndex = months.firstIndex(of: currentMonth) ?? 0
        let yearIndex = years.firstIndex(of: currentYear) ?? 0
        
        datePicker.selectRow(monthIndex, inComponent: 0, animated: false)
        datePicker.selectRow(yearIndex, inComponent: 1, animated: false)
    }
    
    private func dismissView() {
        UIView.animate(withDuration: 0.1) {
            self.view.backgroundColor = .clear
        } completion: { _ in
            self.dismiss(animated: true)
        }
    }
}
//
extension BaseDatePickViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
        label.text = "asdf"
        
        if component == 0 {
            label.text = "\(months[row]) 월"
        } else {
            label.text = "\(years[row]) 년"
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row : \(row), componet : \(component)")
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13, *)
struct BaseDatePickViewController_Preview: PreviewProvider {
    static var previews: some View {
        BaseDatePickViewController(title: "날짜선택").showPreview()
    }
}
#endif

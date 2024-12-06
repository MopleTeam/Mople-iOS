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

final class FullDatePickerViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let pickerView = DatePickerView(title: TextStyle.DatePicker.header,
                                            type: .fullDate)
    
    // MARK: - LifeCycle
    init() {
        print(#function, #line, "LifeCycle Test CalendarDate PickerView Created" )
        super.init(nibName: nil, bundle: nil)
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
        setupDefaultDate()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Default Date
    private func setupDefaultDate() {
        self.pickerView.defaultSelectedDate()
    }
    
    // MARK: - Action
    private func setupAction() {
        self.pickerView.closeButtonTap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.pickerView.completedButtonTap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
//                let selectedDate = vc.pickerView.selectedDate
//                vc.selectedDateObserver.accept(selectedDate)
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

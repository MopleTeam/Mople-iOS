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
    
    // MARK: - UI Components
    private let pickerView = YearMonthPickerView(title: TextStyle.DatePicker.header)
    
    // MARK: - LifeCycle
    init(reactor: Reactor? = nil) {
        print(#function, #line, "LifeCycle Test CalendarDate PickerView Created" )

        defer { self.reactor = reactor }
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
        setupUI()
        setupAction()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Bind
    func bind(reactor: CalendarViewReactor) {
        selectedDateObserver
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.requestPageSwitch(dateComponents: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$changedPage)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, dateComponents in
                vc.pickerView.defaultSelectedDate(on: dateComponents)
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
        
        self.pickerView.completedButtonTap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                let selectedDate = vc.pickerView.selectedDate
                vc.selectedDateObserver.accept(selectedDate)
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

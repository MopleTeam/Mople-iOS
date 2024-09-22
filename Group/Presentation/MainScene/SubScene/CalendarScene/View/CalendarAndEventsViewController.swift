//
//  CalendarViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class CalendarAndEventsViewController: BaseViewController, View {
    
    typealias Reactor = CalendarViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private let currentCalendar = Calendar.current
    
    private lazy var todayComponents = {
        var components = self.currentCalendar.dateComponents([.year, .month, .day], from: Date())
        return components
    }()
    
    // MARK: - Observable
    private let calendarHeightObservable: PublishSubject<CGFloat> = .init()
    private let calendarScopeObservable: PublishSubject<ScopeType> = .init()
    private let eventObservable: BehaviorRelay<[DateComponents]> = .init(value: [])
    private lazy var calendarDateObservable: BehaviorRelay<DateComponents> = .init(value: todayComponents)
    
    // MARK: - UI Components
    private let headerContainerView: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = AppDesign.Calendar.headerColor
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let headerLabel: IconLabelView = {
        let label = IconLabelView(iconSize: 24,
                                  configure: AppDesign.Calendar.header,
                                  iconAligment: .right)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let calendarContainerView = UIView()
    
    private lazy var calendarView: CalendarViewController = {
        let calendarView = CalendarViewController(todayComponents: todayComponents,
                                                  heightObservable: calendarHeightObservable.asObserver(),
                                                  scopeObservable: calendarScopeObservable.asObserver(),
                                                  eventObservable: eventObservable.asObservable(),
                                                  dateObservable: calendarDateObservable)
        
        
        calendarView.view.layer.cornerRadius = 16
        calendarView.view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return calendarView
    }()
    
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = AppDesign.defaultWihte
        return view
    }()
    
    // MARK: - LifeCycle
    init(title: String,
         reactor: CalendarViewReactor) {
         super.init(title: title)
        self.reactor = reactor
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setupUI()
         setObservable()
     }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavi()
        setLayout()
        addScheduleListCollectionView()
    }
    
    private func setupNavi() {
        addRightButton(setImage: .calendar)
    }
    
    private func setLayout() {
        self.view.addSubview(headerContainerView)
        self.view.addSubview(calendarContainerView)
        self.view.addSubview(emptyView)
                
        headerContainerView.addSubview(headerLabel)
        
        headerContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        calendarContainerView.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1) // 최소 높이 설정 (Calender 생성 시 높이 update)
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(calendarContainerView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func addScheduleListCollectionView() {
        addChild(calendarView)
        calendarContainerView.addSubview(calendarView.view)
        calendarView.didMove(toParent: self)
        calendarView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Selectors
    func bind(reactor: CalendarViewReactor) {
        reactor.state
            .map { $0.dates }
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, dates in
                let components = dates.map { vc.currentCalendar.dateComponents([.year, .month, .day], from: $0) }
                vc.eventObservable.accept(components)
            })
            .disposed(by: disposeBag)
    }
    
    private func setObservable() {
        setBinding()
        setAction()
    }
    
    private func setBinding() {
        calendarHeightObservable
            .subscribe(with: self, onNext: { vc, height in
                vc.updateCalendarView(height)
            })
            .disposed(by: disposeBag)
        
        calendarScopeObservable
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, scope in
                vc.updateHeaderView(scope)
                
                vc.updateBackgroundColor(scope: scope)
            })
            .disposed(by: disposeBag)
        
        calendarDateObservable
            .subscribe(with: self, onNext: { vc, date in
                let year = date.year ?? 2024
                let monty = date.month ?? 1
                
                vc.headerLabel.setText("\(year)년 \(monty)월")
            })
            .disposed(by: disposeBag)
    }
    
    private func setAction() {
        headerContainerView.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.presentDatePicker()
            })
            .disposed(by: disposeBag)
            
        rightButtonObservable
            .subscribe(with: self, onNext: { vc, _ in
                vc.calendarView.changeScope()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Date Picker
extension CalendarAndEventsViewController {
    private func presentDatePicker() {
        let datePickView = BaseDatePickViewController(title: "날짜 선택",
                                                      todayComponents: todayComponents,
                                                      dateObservable: calendarDateObservable)
        
        datePickView.modalPresentationStyle = .pageSheet
        
        if let sheet = datePickView.sheetPresentationController {
            sheet.detents = [ .medium() ]
            
        }
        
        self.present(datePickView, animated: true)
    }
}

// MARK: - UI Update
extension CalendarAndEventsViewController {
    private func updateCalendarView(_ height: CGFloat) {
        UIView.animate(withDuration: 0.33) {
            self.calendarContainerView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateHeaderView(_ scope: ScopeType) {
        let height = scope == .month ? 56 : 0

        UIView.animate(withDuration: 0.2) {
            self.headerContainerView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    #warning("참고")
    // 애니메이션 중에는 유저 액션이 차단되는데 이를 허용할 수 있는 옵션이 존재
    private func updateBackgroundColor(scope: ScopeType) {
        let views: [UIView] = [self.calendarContainerView, self.emptyView]
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .allowUserInteraction) {
            
            views.forEach {
                let color = scope == .month ? AppDesign.defaultWihte : AppDesign.mainBackColor
                $0.backgroundColor = color
            }
            
        }
    }
}



//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//@available(iOS 13, *)
//struct TestCalendarAndEventsViewController_Preview: PreviewProvider {
//    static var previews: some View {
//        CalendarAndEventsViewController(title: "일정관리").showPreview()
//    }
//}
//#endif





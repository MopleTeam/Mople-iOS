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
    private let currentCalendar = DateManager.calendar
    private lazy var todayComponents = {
        var components = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        return components
    }()
    
    // MARK: - Observable
    // Calendar
    private let calendarHeightObservable: PublishSubject<CGFloat> = .init()
    private let calendarScopeObservable: PublishSubject<ScopeType> = .init()
    private let calendarScopeChangeObservable: PublishSubject<Void> = .init()
    private let eventArrayObservable: PublishSubject<[DateComponents]> = .init()
        
    // Clendar & DatePicker & MainView
    private let pageChangeRequestObserver: PublishSubject<DateComponents> = .init()
    private let pageChangeNotificationObserver: PublishSubject<DateComponents> = .init()
    
    // Calendar & ScheduleTable
    private let dateObservable: PublishRelay<DateComponents> = .init()
    
    // ScheduleTableView
    private let scheduleListObservable: PublishSubject<[ScheduleTableModel]> = .init()
        
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
    
    // 캘린더
    private let calendarContainer = UIView()
    
    private lazy var calendarView: CalendarViewController = {
        let calendarView = CalendarViewController(todayComponents: todayComponents,
                                                  heightObservable: calendarHeightObservable.asObserver(),
                                                  scopeObservable: calendarScopeObservable.asObserver(),
                                                  pageChangeNotificationObserver: pageChangeNotificationObserver.asObserver(),
                                                  scopeChangeObservable: calendarScopeChangeObservable,
                                                  eventArrayObservable: eventArrayObservable.asObservable(),
                                                  pageChangeRequestObserver: pageChangeRequestObserver,
                                                  dateObservable: dateObservable)
        
        
        calendarView.view.layer.cornerRadius = 16
        calendarView.view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return calendarView
    }()
    
    // 스케쥴 리스트 테이블 뷰
    private let scheduleListContainer = UIView()
    
    private lazy var scheduleListTableView: ScheduleTableViewController = {
        let scheduleListTableView = ScheduleTableViewController(fetchDataObservable: scheduleListObservable.asObservable(),
                                                                dateObservable: dateObservable)
        return scheduleListTableView
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
    
    override func viewDidAppear(_ animated: Bool) {
        pageChangeNotificationObserver.onNext(todayComponents)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavi()
        setLayout()
        setContainer()
    }
    
    private func setupNavi() {
        addRightButton(setImage: .calendar)
        addLeftButton(setImage: .close)
        hideLeftButton(isHidden: true)
    }
    
    private func setLayout() {
        self.view.addSubview(headerContainerView)
        self.view.addSubview(calendarContainer)
        self.view.addSubview(scheduleListContainer)
                
        headerContainerView.addSubview(headerLabel)
        
        headerContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        calendarContainer.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1) // 최소 높이 설정 (Calender 생성 시 높이 update)
        }
        
        scheduleListContainer.snp.makeConstraints { make in
            make.top.equalTo(calendarContainer.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setContainer() {
        addCalendarView()
        addScheduleListView()
    }
    
    private func addCalendarView() {
        addChild(calendarView)
        calendarContainer.addSubview(calendarView.view)
        calendarView.didMove(toParent: self)
        calendarView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addScheduleListView() {
        addChild(scheduleListTableView)
        scheduleListContainer.addSubview(scheduleListTableView.view)
        scheduleListTableView.didMove(toParent: self)
        scheduleListTableView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Selectors
    func bind(reactor: CalendarViewReactor) {
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.fetchData }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$dateComponentsArray)
            .do(onNext: { print($0.count) })
            .bind(to: eventArrayObservable)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$scheduleArray)
            .bind(to: scheduleListObservable)
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
                vc.updateMainView(scope)
            })
            .disposed(by: disposeBag)
        
        pageChangeNotificationObserver
            .do(onNext: { print(#function, #line, "date : \($0)" ) })
            .subscribe(with: self, onNext: { vc, date in
                let year = date.year ?? 2024
                let monty = date.month ?? 1
                
                vc.headerLabel.setText("\(year)년 \(monty)월")
            })
            .disposed(by: disposeBag)
        
        rightButtonObservable
            .bind(to: calendarScopeChangeObservable)
            .disposed(by: disposeBag)
        
        leftButtonObservable
            .bind(to: calendarScopeChangeObservable)
            .disposed(by: disposeBag)
    }
    
    private func setAction() {
        headerContainerView.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.presentDatePicker()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Date Picker
extension CalendarAndEventsViewController {
    private func presentDatePicker() {
        let datePickView = DatePickViewController(title: "날짜 선택",
                                                  todayComponents: todayComponents,
                                                  pageChangeRequestObserver: pageChangeRequestObserver.asObserver(),
                                                  pageChangeNotificationObserver: pageChangeNotificationObserver.asObservable())
        
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
            self.calendarContainer.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateMainView(_ scope: ScopeType) {
        UIView.animate(withDuration: 0.33, delay: 0, options: .allowUserInteraction) {
            self.updateHeaderView(scope: scope)
            self.updateBackgroundColor(scope: scope)
            self.naviItemChange(scope: scope)
            self.hideScheduleListTableView(scope: scope)
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateHeaderView(scope: ScopeType) {
        let height = scope == .month ? 56 : 0
        
        self.headerContainerView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
    
    private func hideScheduleListTableView(scope: ScopeType) {
        scheduleListTableView.hideView(isHide: scope == .month)
    }
    
#warning("참고")
    // 애니메이션 중에는 유저 액션이 차단되는데 이를 허용할 수 있는 옵션이 존재
    private func updateBackgroundColor(scope: ScopeType) {
        let views: [UIView] = [self.calendarContainer, self.scheduleListContainer]
        
        views.forEach {
            let color = scope == .month ? AppDesign.defaultWihte : AppDesign.mainBackColor
            $0.backgroundColor = color
        }
    }
    
    private func naviItemChange(scope: ScopeType) {
        let isScopeMonth = scope == .month
        
        hideRightButton(isHidden: !isScopeMonth)
        hideLeftButton(isHidden: isScopeMonth)
    }
}









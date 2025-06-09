//
//  CalendarViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class CalendarPostViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = CalendarPostViewReactor
    var disposeBag = DisposeBag()
        
    // MARK: - Observable
    private let monthSelectedObserver: BehaviorSubject<Date?> = .init(value: nil)
    
    // MARK: - Gesture
    private let panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer()
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    // MARK: - UI Components
    private let headerButton: UIButton = {
        let view = UIButton()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = .bgPrimary
        return view
    }()
    
    private let header: IconLabel = {
        let header = IconLabel(icon: .downArrow,
                               iconSize: .init(width: 24, height: 24))
        header.setTitle(font: FontStyle.Title3.semiBold,
                        color: .gray01)
        header.setIconAligment(.right)
        header.isUserInteractionEnabled = false
        return header
    }()
    
    private let calendarContainer: UIView = {
        let view = UIView()
        view.layer.zPosition = 1
        return view
    }()
        
    private let scheduleListContainer: UIView = {
        let view = UIView()
        view.layer.zPosition = 2
        view.clipsToBounds = true
        return view
    }()
        
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .defaultWhite
        view.layer.makeCornes(radius: 16, corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        return view
    }()
    
    // MARK: - Child VC
    private let calendarVC: CalendarViewController
    private let scheduleVC: PostListViewController
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         calendarVC: CalendarViewController,
         scheduleVC: PostListViewController,
         reactor: CalendarPostViewReactor) {
        self.calendarVC = calendarVC
        self.scheduleVC = scheduleVC
        super.init(screenName: screenName,
                   title: title)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setChildVC()
        setAction()
        setGesture()
    }
    
    private var isFirst: Bool = true
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavi()
        setLayout()
        setHeaderLabel(DateManager.todayComponents)
    }
    
    private func setupNavi() {
        self.setBarItem(type: .left)
        self.setBarItem(type: .right, image: .calendar)
        self.hideBaritem(type: .left, isHidden: true)
    }
    
    private func setLayout() {
        self.view.addSubview(headerButton)
        self.view.addSubview(borderView)
        self.view.addSubview(calendarContainer)
        self.view.addSubview(scheduleListContainer)
        self.headerButton.addSubview(header)
        
        headerButton.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
        
        header.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        calendarContainer.snp.makeConstraints { make in
            make.top.equalTo(headerButton.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(360)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(calendarContainer)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(calendarContainer).offset(1)
        }
    }
    
    
    // MARK: - Set ChildVC
    private func setChildVC() {
        self.add(child: calendarVC, container: calendarContainer)
        self.add(child: scheduleVC, container: scheduleListContainer)
    }
    
    // MARK: - Action
    private func setAction() {
        headerButton.rx.controlEvent(.touchUpInside)
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.presentDatePicker()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Gestrue
    private func setGesture() {
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
        calendarVC.setPanGesture(gesture: panGesture)
        scheduleVC.panGestureRequire(panGesture)
    }
}

// MARK: - Reactor Setup
extension CalendarPostViewController {
 
    func bind(reactor: CalendarPostViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
        setNotificationBind(reactor)
    }
    
    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        naviBar.rightItemEvent
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.changeScope }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        naviBar.leftItemEvent
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.changeScope }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        let monthObserver = monthSelectedObserver
            .compactMap({ $0 })
            .observe(on: MainScheduler.asyncInstance)
        
        monthObserver
            .map { Reactor.Action.changeMonth($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        monthObserver
            .subscribe(with: self, onNext: { vc, month in
                vc.setHeaderLabel(month.toDateComponents())
            })
            .disposed(by: disposeBag)
    }
    
    private func setNotificationBind(_ reactor: Reactor) {
        NotificationManager.shared.addPlanObservable()
            .map { Reactor.Action.notify(.updatePlan($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addParticipatingObservable()
            .map { Reactor.Action.notify(.updatePlan($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addMeetObservable()
            .map { Reactor.Action.notify(.updateMeet($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addReviewObservable()
            .map { Reactor.Action.notify(.updateReview($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addObservable(name: .midnightUpdate)
            .map { Reactor.Action.notify(.midnightUpdate) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$changeMonth)
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, dateComponents in
                vc.setHeaderLabel(dateComponents)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$scope)
            .skip(1)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .month)
            .drive(with: self, onNext: { vc, scope in
                vc.updateView(scope)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, err in
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 에러 핸들링
    private func handleError(_ err: CalendarError) {
        switch err {
        case let .midnight(err):
            alertManager.showDateErrorMessage(err: err)
        case .unknown:
            alertManager.showDefatulErrorMessage()
        }
    }
}

extension CalendarPostViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /// 캘린더뷰외의 공간에서도 캘린더 스크롤 or 스코프 전환을 위한 플래그
    /// Month : 캘린더뷰 외의 지점에서 시작하면 true
    ///     - 수직 스크롤 : 스코프 전환
    ///     - 수평 스크롤 : 월 전환
    /// Week : 지점에 상관없이 스코프 전환
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let currentScope = reactor?.currentState.scope
        
        guard !checkGestureLocationInCalendar() || !checkHorizonGesture() else { return false }
        return currentScope == .month ? true : checkHorizonGesture()
    }
    
    /// 제스처 시작 지점이 캘린더에 있는지 체크
    private func checkGestureLocationInCalendar() -> Bool {
        let gestureLoaction = panGesture.location(in: self.view)
        return calendarContainer.frame.contains(gestureLoaction)
    }

    /// 수평으로 제스처를 했는지 체크
    private func checkHorizonGesture() -> Bool {
        let velocity = self.panGesture.velocity(in: self.view)
        return abs(velocity.x) > abs(velocity.y)
    }
}

// MARK: - Date Picker
extension CalendarPostViewController {
    private func presentDatePicker() {
        let defaultDate = reactor?.currentState.changeMonth ?? Date().toDateComponents()
        let datePickView = YearMonthPickerViewController(defaultDate: defaultDate)
        datePickView.completed = { [weak self] selectedMonth in
            guard let monthDate = selectedMonth.toDate() else { return }
            self?.monthSelectedObserver.onNext(monthDate)
        }
        datePickView.modalPresentationStyle = .pageSheet
        if let sheet = datePickView.sheetPresentationController {
            sheet.detents = [ .medium() ]
        }
        self.present(datePickView, animated: true)
    }
}

// MARK: - UI Update
extension CalendarPostViewController {
    private func updateView(_ scope: ScopeType) {
        self.updateBackgroundColor(scope: scope)
        UIView.animate(withDuration: 0.33) {
            self.updateCalendarView(scope: scope)
            self.updateScheduleListView(scope: scope)
            self.updateHeaderView(scope: scope)
            self.naviItemChange(scope: scope)
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateHeaderView(scope: ScopeType) {
        let height = scope == .month ? 56 : 0
        let offset: CGFloat = scope == .month ? 16 : 0
        self.headerButton.snp.updateConstraints { make in
            make.top.equalTo(titleViewBottom).offset(offset)
            make.height.equalTo(height)
        }
    }
    
    private func updateCalendarView(scope: ScopeType) {
        guard let calendarHeight = calendarVC.currentHeight else { return }
        let offset: CGFloat = scope == .month ? 16 : 0
        calendarContainer.snp.updateConstraints { make in
            make.top.equalTo(headerButton.snp.bottom).offset(offset)
            make.height.equalTo(calendarHeight)
        }
    }
    
    private func updateScheduleListView(scope: ScopeType) {
        let baseLine = scope == .month ? self.view.snp.bottom : borderView.snp.bottom
        
        scheduleListContainer.snp.remakeConstraints({ make in
            make.top.equalTo(baseLine)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom)
        })
    }
    
    private func updateBackgroundColor(scope: ScopeType) {
        self.view.backgroundColor = scope == .month ? .defaultWhite : .bgPrimary
        self.calendarContainer.backgroundColor = scope == .month ? .defaultWhite : .bgPrimary
        self.borderView.backgroundColor = scope == .month ? .defaultWhite : .appStroke
    }
    
    private func naviItemChange(scope: ScopeType) {
        let isScopeMonth = scope == .month
        
        self.hideBaritem(type: .right, isHidden: !isScopeMonth)
        self.hideBaritem(type: .left, isHidden: isScopeMonth)
    }
    
    private func setHeaderLabel(_ dateComponents: DateComponents) {
        let year = dateComponents.year ?? 2020
        let month = dateComponents.month ?? 01
        header.text = L10n.Calendar.header("\(year)", "\(month)")
    }
}

// MARK: - From HomeView
extension CalendarPostViewController {
    public func presentEvent(on lastRecentDate: Date) {
        monthSelectedObserver.onNext(lastRecentDate)
    }
}


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

final class CalendarScheduleViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = CalendarScheduleViewReactor
    private var calendarScheduleReactor: CalendarScheduleViewReactor?
    var disposeBag = DisposeBag()
        
    // MARK: - Observable
    private let monthSelectedObserver: BehaviorSubject<Date?> = .init(value: nil)
    public let panGestureObserver: PublishSubject<UIPanGestureRecognizer> = .init()
    
    // MARK: - Gesture
    public let scopeGesture: UIPanGestureRecognizer = {
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
        view.backgroundColor = ColorStyle.BG.primary
        return view
    }()
    
    private let header: IconLabel = {
        let header = IconLabel(icon: .downArrow,
                               iconSize: .init(width: 24, height: 24))
        header.setTitle(font: FontStyle.Title3.semiBold,
                        color: ColorStyle.Gray._01)
        header.setIconAligment(.right)
        header.isUserInteractionEnabled = false
        return header
    }()
    
    public let calendarContainer: UIView = {
        let view = UIView()
        view.layer.zPosition = 2
        return view
    }()
        
    public let scheduleListContainer = UIView()
        
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.Default.white
        view.layer.makeCornes(radius: 16, corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        view.layer.zPosition = 1
        return view
    }()
    
    // MARK: - LifeCycle
    init(title: String,
         reactor: CalendarScheduleViewReactor) {
        super.init(title: title)
        self.calendarScheduleReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        super.viewDidLoad()
        setupUI()
        setReactor()
        setAction()
        setGesture()
    }
    
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
        self.headerButton.addSubview(header)
        self.view.addSubview(borderView)
        self.view.addSubview(calendarContainer)
        self.view.addSubview(scheduleListContainer)
        
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
        
        scheduleListContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(calendarContainer)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(calendarContainer).offset(1)
        }
    }
    
    // MARK: - Action
    private func setAction() {
        headerButton.rx.controlEvent(.touchUpInside)
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.presentDatePicker()
            })
            .disposed(by: disposeBag)
        
        scopeGesture.rx.event
            .asDriver()
            .drive(panGestureObserver)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Gestrue
    private func setGesture() {
        scopeGesture.delegate = self
        self.view.addGestureRecognizer(scopeGesture)
    }
}

// MARK: - Reactor Setup
extension CalendarScheduleViewController {
    private func setReactor() {
        reactor = calendarScheduleReactor
    }
    
    func bind(reactor: CalendarScheduleViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
        setNotification(reactor: reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
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
    
    private func outputBind(_ reactor: Reactor) {
        reactor.pulse(\.$changeMonth)
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, dateComponents in
                vc.setHeaderLabel(dateComponents)
            })
            .disposed(by: disposeBag)

        reactor.pulse(\.$calendarHeight)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, height in
                vc.updateCalendarView(height)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$scope)
            .skip(1)
            .asDriver(onErrorJustReturn: .month)
            .drive(with: self, onNext: { vc, scope in
                vc.updateMainView(scope)
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
    
    private func setNotification(reactor: Reactor) {
        EventService.shared.addPlanObservable()
            .map { Reactor.Action.updatePlan($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        EventService.shared.addParticipatingObservable()
            .map { Reactor.Action.updatePlan($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        EventService.shared.addMeetObservable()
            .map { Reactor.Action.updateMeet($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        EventService.shared.addReviewObservable()
            .map { Reactor.Action.updateReview($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        EventService.shared.addObservable(name: .midnightUpdate)
            .map { Reactor.Action.midnightUpdate }
            .bind(to: reactor.action)
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

extension CalendarScheduleViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /// 제스처 시작지점이 캘린더의 밖이거나 수직 제스처라면 true
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let currentScope = reactor?.currentState.scope
        
        guard !checkGestureLocationInCalendar() || !checkHorizonGesture() else { return false }
        return currentScope == .month ? true : checkHorizonGesture()
    }
    
    /// 제스처 시작 지점이 캘린더에 있는지 체크
    private func checkGestureLocationInCalendar() -> Bool {
        let gestureLoaction = scopeGesture.location(in: self.view)
        return calendarContainer.frame.contains(gestureLoaction)
    }

    /// 수평으로 제스처를 했는지 체크
    private func checkHorizonGesture() -> Bool {
        let velocity = self.scopeGesture.velocity(in: self.view)
        return abs(velocity.x) > abs(velocity.y)
    }
}

// MARK: - Date Picker
extension CalendarScheduleViewController {
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
extension CalendarScheduleViewController {
    private func updateCalendarView(_ height: CGFloat) {
        UIView.animate(withDuration: 0.33) {
            self.calendarContainer.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateMainView(_ scope: ScopeType) {
        UIView.animate(withDuration: 0.33) {
            self.hideScheduleListView(scope: scope)
            self.updateHeaderView(scope: scope)
            self.updateBackgroundColor(scope: scope)
            self.naviItemChange(scope: scope)
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateHeaderView(scope: ScopeType) {
        let height = scope == .month ? 56 : 0
        
        self.headerButton.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
    
    private func hideScheduleListView(scope: ScopeType) {
        let baseLine = scope == .month ? view.safeAreaLayoutGuide.snp.bottom : calendarContainer.snp.bottom
        
        scheduleListContainer.snp.remakeConstraints({ make in
            make.top.equalTo(baseLine)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        })
    }
    
    private func updateBackgroundColor(scope: ScopeType) {
        self.calendarContainer.backgroundColor = scope == .month ? ColorStyle.Default.white : ColorStyle.BG.primary
        self.scheduleListContainer.backgroundColor = scope == .month ? ColorStyle.Default.white : ColorStyle.BG.primary
        self.borderView.backgroundColor = scope == .month ? ColorStyle.Default.white : ColorStyle.App.stroke
    }
    
    private func naviItemChange(scope: ScopeType) {
        let isScopeMonth = scope == .month
        
        self.hideBaritem(type: .right, isHidden: !isScopeMonth)
        self.hideBaritem(type: .left, isHidden: isScopeMonth)
    }
    
    private func setHeaderLabel(_ dateComponents: DateComponents) {
        let year = dateComponents.year ?? 2020
        let monty = dateComponents.month ?? 01
        header.text = "\(year)년 \(monty)월"
    }
}

// MARK: - From HomeView
extension CalendarScheduleViewController {
    public func presentEvent(on lastRecentDate: Date) {
        monthSelectedObserver.onNext(lastRecentDate)
    }
}


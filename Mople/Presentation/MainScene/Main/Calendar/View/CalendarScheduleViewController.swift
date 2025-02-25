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
    
    typealias Reactor = CalendarScheduleViewReactor
    
    // MARK: - Variables
    var disposeBag = DisposeBag()
        
    // MARK: - Observer
    private let presentEventObserver: BehaviorRelay<Date?> = .init(value: nil)
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
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        super.viewDidLoad()
        setupUI()
        setAction()
        setGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function, #line)
        super.viewWillDisappear(animated)
        resetPresentDate()
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
            make.top.equalTo(view.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(calendarContainer)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(calendarContainer).offset(1)
        }
    }
    
    // MARK: - Binding
    func bind(reactor: CalendarScheduleViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        reactor.pulse(\.$changedPage)
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
            .drive(with: self, onNext: { vc, isLoad in
                vc.rx.isLoading.onNext(isLoad)
                vc.checkIsPresent(isLoad)
            })
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        naviBar.rightItemEvent
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.requestScopeSwitch(type: .buttonTap) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        naviBar.leftItemEvent
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.requestScopeSwitch(type: .buttonTap) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.presentEventObserver
            .observe(on: MainScheduler.instance)
            .compactMap({ $0 })
            .map { Reactor.Action.requestPresentEvent(lastRecentDate: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
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
    
    private func setGesture() {
        scopeGesture.delegate = self
        self.view.addGestureRecognizer(scopeGesture)
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
        let datePickView = YearMonthPickerViewController(reactor: reactor)
        
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
        let baseLine = scope == .month ? view.snp.bottom : calendarContainer.snp.bottom
        
        scheduleListContainer.snp.remakeConstraints({ make in
            make.top.equalTo(baseLine)
            make.horizontalEdges.bottom.equalToSuperview()
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

// MARK: - Home View에서 넘어왔을 때의 액션
extension CalendarScheduleViewController {
    
    /// 표시할 데이터가 있는 상태 : 홈뷰에서 표시한 이벤트 갯수 넘기기
    public func presentEvent(on lastRecentDate: Date) {
        self.presentEventObserver.accept(lastRecentDate)
    }
    
    #warning("홈화면에서 캘린더로 넘어올 때 테이블뷰가 윈도우에 추가되지 않은 경우 아래에 표시된 에러 발생")
    #warning("현재는 기본 로딩이 끝난 뒤 체크하는 중 차후에 로딩이 발생하면 다시 실행됨")
    /// 표시할 데이터가 없는 상태 : 로딩이 끝난 후 presentNextEvent count 다시 보내주기
    private func checkIsPresent(_ isLoading: Bool) {
        guard !isLoading,
              let recentEventCount = presentEventObserver.value else { return }
        presentEventObserver.accept(recentEventCount)
    }
    
    /// 화면을 벗어날 때 설정값 지우기
    private func resetPresentDate() {
        guard presentEventObserver.value == nil else { return }
        presentEventObserver.accept(nil)
    }
}


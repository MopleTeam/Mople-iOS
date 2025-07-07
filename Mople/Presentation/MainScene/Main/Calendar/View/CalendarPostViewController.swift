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
    
    // MARK: - Variables
    private var currentMonth: DateComponents?
    
    // MARK: - Constratint
    private var calendarHeightConstraint: Constraint?
    private var calendarBottomConstraint: Constraint?
    
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
        view.clipsToBounds = false
        view.backgroundColor = .clear
        return view
    }()
        
    private let postListContainer: UIView = {
        let view = UIView()
        view.layer.zPosition = 2
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Child VC
    private let calendarVC: CalendarViewController
    private let postListVC: PostListViewController
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         calendarVC: CalendarViewController,
         scheduleVC: PostListViewController,
         reactor: CalendarPostViewReactor) {
        self.calendarVC = calendarVC
        self.postListVC = scheduleVC
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
    }
    
    private var isFirst: Bool = true
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavi()
        setLayout()
        setCurrentMonth(currentMonth?.toDate() ?? Date())
    }
    
    private func setupNavi() {
        self.setBarItem(type: .right, image: .dotlist)
    }
    
    private func setLayout() {
        self.view.addSubview(headerButton)
        self.view.addSubview(calendarContainer)
        self.view.addSubview(postListContainer)
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
            make.top.equalTo(headerButton.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            calendarHeightConstraint = make.height.equalTo(0).priority(750).constraint
            calendarBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide).priority(1000).constraint
        }
        
        postListContainer.snp.makeConstraints({ make in
            make.top.equalTo(calendarContainer.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().priority(.high)
        })
    }
    
    // MARK: - Set ChildVC
    private func setChildVC() {
        self.add(child: calendarVC, container: calendarContainer)
        self.add(child: postListVC, container: postListContainer)
        calendarVCBind()
        postListVCBind()
    }
    
    // MARK: - ChildVC Bind
    private func calendarVCBind() {
        calendarVC.rx.scope
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { vc, scope in
                vc.updateView(scope)
            })
            .disposed(by: disposeBag)
        
        calendarVC.rx.month
            .bind(with: self, onNext: { vc, month in
                vc.setCurrentMonth(month)
                vc.postListVC.fetchMonthlyEvent(in: month)
            })
            .disposed(by: disposeBag)
        
        calendarVC.rx.selectedDate
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { vc, date in
                vc.postListVC.scrollToDate(at: date)
            })
            .disposed(by: disposeBag)
        
        calendarVC.rx.height
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { vc, height in
                vc.calendarHeightConstraint?.update(offset: height)
            })
            .disposed(by: disposeBag)
    }
    
    private func postListVCBind() {
        postListVC.rx.foucsDate
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { vc, date in
                vc.calendarVC.selectedPresnetDate(on: date)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action
    private func setAction() {
        naviBar.rightItemEvent
            .bind(with: self, onNext: { vc, _ in
                vc.calendarVC.switchScope(type: .buttonTap)
            })
            .disposed(by: disposeBag)
        
        headerButton.rx.controlEvent(.touchUpInside)
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.presentDatePicker()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Setup
extension CalendarPostViewController {
 
    func bind(reactor: CalendarPostViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setFlowActionBind(reactor)
        setNotifyActionBind(reactor)
    }
    
    private func setNotifyActionBind(_ reactor: Reactor) {
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
    
    private func setFlowActionBind(_ reactor: Reactor) {
        postListVC.rx.selectedPost
            .map { Reactor.Action.flow(.postDetail($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
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

// MARK: - Data Request And Move Page
extension CalendarPostViewController {
    private func moveSpectificMonth(at month: Date) {
        postListVC.fetchSpecificMonth(at: month)
        setCurrentMonth(month)
        calendarVC.moveToPage(on: month)
    }
}

// MARK: - Date Picker
extension CalendarPostViewController {
    private func presentDatePicker() {
        let defaultDate = currentMonth ?? Date().toDateComponents()
        let datePickView = YearMonthPickerViewController(defaultDate: defaultDate)
        datePickView.completed = { [weak self] selectedMonth in
            guard let monthDate = selectedMonth.toDate() else { return }
            self?.moveSpectificMonth(at: monthDate)
        }
        
        self.present(datePickView, animated: true)
    }
}

// MARK: - UI Update
extension CalendarPostViewController {
    private func updateView(_ scope: ScopeType) {
        naviItemChange(scope: scope)
        UIView.animate(withDuration: 0.33,
                       animations: { [weak self] in
            self?.updateCalendarView(scope: scope)
            self?.updateHeaderView(scope: scope)
            self?.updateBackgroundColor(scope: scope)
            self?.view.layoutIfNeeded()
        })
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
        calendarBottomConstraint?.isActive = scope == .month
    }
    
    private func updateBackgroundColor(scope: ScopeType) {
        self.postListContainer.backgroundColor = scope == .month ? .defaultWhite : .bgPrimary
    }
    
    private func naviItemChange(scope: ScopeType) {
        let image: UIImage = scope == .month ? .dotlist : .calendar
        self.naviBar.setBarItem(type: .right, image: image)
        view.layoutIfNeeded()
    }
    
    private func setCurrentMonth(_ month: Date) {
        currentMonth = month.toDateComponents()
        setHeaderLabel(currentMonth!)
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
        moveSpectificMonth(at: lastRecentDate)
    }
}


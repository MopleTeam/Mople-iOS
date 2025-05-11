//
//  PlanCreateViewController.swift
//  Mople
//
//  Created by CatSlave on 11/20/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class CreatePlanViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = CreatePlanViewReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Variables
    private let createType: PlanCreationType
    
    // MARK: - Observables
    private let endFlow: PublishSubject<Void> = .init()
    private let selectedMeet: PublishSubject<Int> = .init()
    private let selectDay: PublishSubject<DateComponents?> = .init()
    private let selectTime: PublishSubject<DateComponents?> = .init()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let meetSelectView: LabeledButton = {
        let btn = LabeledButton(title: L10n.Createplan.meetInput,
                                inputText: L10n.Createplan.meetPlaceholder)
        return btn
    }()
    
    private let planTitleView: LabeledTextField = {
        let view = LabeledTextField(title: L10n.Createplan.nameInput,
                                    placeholder: L10n.Createplan.namePlaceholder,
                                    maxTextCount: 30)
        return view
    }()
    
    private let dateSelectView: LabeledButton = {
        let btn = LabeledButton(title: L10n.Createplan.dateInput,
                                inputText: L10n.Createplan.datePlaceholder,
                                icon: .smallCalendar)
        return btn
    }()
    
    private let timeSelectView: LabeledButton = {
        let btn = LabeledButton(title: L10n.Createplan.timeInput,
                                inputText: L10n.Createplan.timePlaceholder,
                                icon: .clock)
        return btn
    }()
    
    private let placeSelectView: LabeledButton = {
        let btn = LabeledButton(title: L10n.Createplan.placeInput,
                                inputText: L10n.Createplan.placePlaceholder,
                                icon: .location)
        return btn
    }()
    
    private let completeButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(font: FontStyle.Title3.semiBold,
                     normalColor: .defaultWhite)
        btn.setBgColor(normalColor: .appPrimary,
                       disabledColor: .disablePrimary)
        btn.setRadius(8)
        btn.rx.isEnabled.onNext(false)
        return btn
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            meetSelectView, planTitleView, dateSelectView,
            timeSelectView, placeSelectView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 24
        return stackView
    }()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         type: PlanCreationType,
         reactor: CreatePlanViewReactor) {
        self.createType = type
        super.init(screenName: screenName,
                   title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTapKeyboardDismiss()
        setAction()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setNaviItem()
        setLayout()
        setCompleteTitle()
    }
    
    private func setLayout() {
        self.view.backgroundColor = .defaultWhite
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(mainStackView)
        self.contentView.addSubview(completeButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            make.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide.snp.height)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(completeButton.snp.top)
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(mainStackView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(mainStackView)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().inset(UIScreen.getDefaultBottomPadding())
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    private func setCompleteTitle() {
        switch createType {
        case .edit:
            completeButton.title = L10n.editPlan
        default:
            completeButton.title = L10n.createPlan
        }
    }
    
    private func setAction() {
        self.timeSelectView.button.rx.controlEvent(.touchUpInside)
            .asDriver()
            .map({ [weak self] in
                return self?.reactor?.currentState.selectedTime
            })
            .drive(with: self, onNext: { vc, time in
                vc.presentTimePickerVC(defaultTime: time)
            })
            .disposed(by: disposeBag)
        
        self.dateSelectView.button.rx.controlEvent(.touchUpInside)
            .asDriver()
            .map({ [weak self] in
                return self?.reactor?.currentState.selectedDay
            })
            .drive(with: self, onNext: { vc, day in
                vc.presentDatePickerVC(defaultDate: day)
            })
            .disposed(by: disposeBag)
        
        self.meetSelectView.button.rx.controlEvent(.touchUpInside)
            .asDriver()
            .compactMap({ [weak self] in
                return self?.reactor?.currentState.meets
            })
            .drive(with: self, onNext: { vc, meetList in
                vc.presentMeetPickerVC(meetList: meetList)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Select Components Flow
extension CreatePlanViewController {
    
    // MARK: - 모임 선택
    private func presentMeetPickerVC(meetList: [MeetSummary]) {
        let meetPickerVC = MeetSelectViewController(meetList: meetList,
                                                    completion: { [weak self] selectedIndex in
            self?.selectedMeet.onNext(selectedIndex)
        })
        
        self.present(meetPickerVC, animated: true)
    }
    
    // MARK: - 날짜 선택
    private func presentDatePickerVC(defaultDate: DateComponents?) {
        let datePikcerVC = DateSelectViewController(selectedDate: defaultDate,
                                                    completion: { [weak self] selectedDate in
            self?.selectDay.onNext(selectedDate)
        })
        
        self.present(datePikcerVC, animated: true)
    }
    
    // MARK: - 시간 선택
    private func presentTimePickerVC(defaultTime: DateComponents?) {
        let timePickerVC = TimePickerViewController(selectedTime: defaultTime,
                                                    completion: { [weak self] selectedTime in
            self?.selectTime.onNext(selectedTime)
        })
        
        self.present(timePickerVC, animated: true)
    }
}

// MARK: - Reactor Setup
extension CreatePlanViewController {

    func bind(reactor: CreatePlanViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: CreatePlanViewReactor) {
        setActionBind(reactor)
        setNotificationBind(reactor)
        setFlowActionBind(reactor)
    }

    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        planTitleView.textField.rx.text
            .skip(1)
            .compactMap { $0 }
            .map({ Reactor.Action.setValue(.name($0)) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        completeButton.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.requestPlanCreation })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        selectedMeet
            .map({ Reactor.Action.setValue(.meet($0)) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        selectTime
            .compactMap({ $0 })
            .map({ Reactor.Action.setValue(.date($0, type: .time)) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        selectDay
            .compactMap({ $0 })
            .map({ Reactor.Action.setValue(.date($0, type: .day)) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
 
    private func setFlowActionBind(_ reactor: CreatePlanViewReactor) {
        naviBar.leftItemEvent
            .map({ Reactor.Action.flow(.endProcess) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        endFlow
            .map({ Reactor.Action.flow(.endProcess) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.placeSelectView.button.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.flow(.placeSelectView) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setNotificationBind(_ reactor: Reactor) {
        NotificationManager.shared.addMeetObservable()
            .map { Reactor.Action.notify(.meet($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$seletedMeet)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0?.name }
            .drive(meetSelectView.rx.selectedText)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedDay)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0?.toDate() })
            .map({ DateManager.toString(date: $0, format: .simple) })
            .drive(dateSelectView.rx.selectedText)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$planTitle)
            .filter { [weak self] _ in
                guard let text = self?.planTitleView.text else { return true }
                return text.isEmpty
            }
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, title in
                vc.planTitleView.rx.text.onNext(title)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedTime)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0?.toDate() })
            .map({
                DateManager.toString(date: $0, format: .time)
            })
            .drive(timeSelectView.rx.selectedText)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedPlace)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0?.title })
            .drive(placeSelectView.rx.selectedText)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isSelectMeetAvaliable)
            .asDriver(onErrorJustReturn: false)
            .drive(meetSelectView.rx.isEnabled)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.canComplete }
            .bind(to: completeButton.rx.isEnabled)
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
    private func handleError(_ err: CreatePlanError) {
        switch err {
        case let .midnight(err):
            alertManager.showDateErrorMessage(err: err,
                                              completion: { [weak self] in
                self?.endFlow.onNext(())
            })
        case let .noResponse(responseError):
            alertManager.showResponseErrorMessage(err: responseError)
        case .unknown:
            alertManager.showDefatulErrorMessage()
        case .invalid:
            guard let message = err.info else { return }
            alertManager.showDefaultAlert(title: message)
        }
    }
}

extension CreatePlanViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    var tapGestureShouldCancelTouchesInView: Bool { false }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}




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
    private var createPlanReactor: CreatePlanViewReactor?
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Observables
    private let endFlow: PublishSubject<Void> = .init()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let meetSelectView: LabeledButtonView = {
        let btn = LabeledButtonView(title: TextStyle.CreatePlan.meet,
                                    inputText: TextStyle.CreatePlan.meetInfo)
        return btn
    }()
    
    private let planTitleView: LabeledTextFieldView = {
        let view = LabeledTextFieldView(title: TextStyle.CreatePlan.plan,
                                        placeholder: TextStyle.CreatePlan.planInfo,
                                        maxTextCount: 30)
        return view
    }()
    
    private let dateSelectView: LabeledButtonView = {
        let btn = LabeledButtonView(title: TextStyle.CreatePlan.date,
                                    inputText: TextStyle.CreatePlan.dateInfo,
                                    icon: .smallCalendar)
        return btn
    }()
    
    private let timeSelectView: LabeledButtonView = {
        let btn = LabeledButtonView(title: TextStyle.CreatePlan.time,
                                    inputText: TextStyle.CreatePlan.timeInfo,
                                    icon: .clock)
        return btn
    }()
    
    private let placeSelectView: LabeledButtonView = {
        let btn = LabeledButtonView(title: TextStyle.CreatePlan.place,
                                    inputText: TextStyle.CreatePlan.placeInfo,
                                    icon: .location)
        return btn
    }()
    
    private let completeButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.CreatePlan.completedTitle,
                     font: FontStyle.Title3.semiBold,
                     normalColor: ColorStyle.Default.white)
        btn.setBgColor(normalColor: ColorStyle.App.primary,
                       disabledColor: ColorStyle.Primary.disable)
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
    init(title: String?,
         reactor: CreatePlanViewReactor?) {
        super.init(title: title)
        self.createPlanReactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
        setupTapKeyboardDismiss()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setNaviItem()
        setLayout()
    }
    
    private func setLayout() {
        self.view.backgroundColor = ColorStyle.Default.white
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
}

// MARK: - Reactor Setup
extension CreatePlanViewController {
    private func setReactor() {
        reactor = createPlanReactor
    }
    
    func bind(reactor: CreatePlanViewReactor) {
        setFlowAction(reactor)
        inputBind(reactor)
        outputBind(reactor)
        setNotification(reactor)
    }
    
    private func inputBind(_ reactor: CreatePlanViewReactor) {
        reactor.pulse(\.$previousPlan)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, _ in
                vc.meetSelectView.rx.isEnabled.onNext(false)
                vc.completeButton.title = "일정 수정"
            })
            .disposed(by: disposeBag)
        
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

    private func outputBind(_ reactor: CreatePlanViewReactor) {
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
    }
    
    // MARK: - Flow Action
    private func setFlowAction(_ reactor: CreatePlanViewReactor) {
        naviBar.leftItemEvent
            .map({ Reactor.Action.flow(.endProcess) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        endFlow
            .map({ Reactor.Action.flow(.endProcess) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.meetSelectView.button.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.flow(.groupSelectView) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.dateSelectView.button.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.flow(.dateSelectView) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.timeSelectView.button.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.flow(.timeSelectView) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.placeSelectView.button.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.flow(.placeSelectView) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Notify
    private func setNotification(_ reactor: Reactor) {
        NotificationManager.shared.addMeetObservable()
            .map { Reactor.Action.updateMeet($0) }
            .bind(to: reactor.action)
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
            alertManager.showAlert(title: message)
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




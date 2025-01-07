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

final class PlanCreateViewController: TitleNaviViewController, View {
    
    typealias Reactor = PlanCreateViewReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Alert
    private let alertManager = AlertManager.shared
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    
    private let contentView = UIView()
    
    private let groupSelectView: LabeledButtonView = {
        let btn = LabeledButtonView(title: TextStyle.CreatePlan.group,
                                    inputText: TextStyle.CreatePlan.groupInfo)
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
    
    private let emptyView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
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
            groupSelectView, planTitleView, dateSelectView,
            timeSelectView, placeSelectView, emptyView
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }()
    
    // MARK: - LifeCycle
    init(title: String?,
         reactor: PlanCreateViewReactor?) {
        print(#function, #line, "LifeCycle Test PlanCreateView Created" )
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test PlanCreateView Deinit" )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }
    
    private func initalSetup() {
        setupLayout()
        setNaviItem()
        setupKeyboardDismissGestrue()
    }
    
    private func setupLayout() {
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
            make.bottom.equalTo(completeButton.snp.top)
        }
        
        completeButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(mainStackView)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().inset(UIScreen.getBottomSafeAreaHeight())
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    // 날짜 이름만 리액터에 연결, 모임 id, 날짜, 시간, 장소는 각 뷰에서 넘겨줘야 함
    // 추가로 받을 것 모든 데이터 입력됐을 시 completed버튼 활성화
    func bind(reactor: PlanCreateViewReactor) {
        setFlowAction(reactor: reactor)
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: PlanCreateViewReactor) {
        reactor.pulse(\.$seletedMeet)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0?.name }
            .drive(groupSelectView.rx.selectedText)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedDay)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0?.toDate() })
            .map({
                print(#function, #line, "#3 : \($0)" )
                return DateManager.toString(date: $0, format: .simple)
            })
            .drive(dateSelectView.rx.selectedText)
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
        
        reactor.pulse(\.$message)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "요청에 실패했습니다.")
            .drive(with: self, onNext: { vc, message in
                vc.alertManager.showAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isAllFieldsFilled }
            .bind(to: completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }

    private func outputBind(_ reactor: PlanCreateViewReactor) {
        planTitleView.textField.rx.text
            .compactMap { $0 }
            .map({ Reactor.Action.setValue(.name($0)) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        completeButton.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.requestPlanCreation })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setFlowAction(reactor: PlanCreateViewReactor) {
        naviBar.leftItemEvent
            .map({ Reactor.Action.flowAction(.endProcess) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.groupSelectView.button.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.flowAction(.groupSelectView) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.dateSelectView.button.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.flowAction(.dateSelectView) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.timeSelectView.button.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.flowAction(.timeSelectView) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.placeSelectView.button.rx.controlEvent(.touchUpInside)
            .map({ Reactor.Action.flowAction(.placeSelectView) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

extension PlanCreateViewController {
    public func setupPlace(_ place: PlaceInfo) {
        self.reactor?.action.onNext(.setValue(.place(place)))
    }
}

extension PlanCreateViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    var tapGestureShouldCancelTouchesInView: Bool { false }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func setupKeyboardDismissGestrue() {
        setupPanKeyboardDismiss()
        setupTapKeyboardDismiss()
    }
}




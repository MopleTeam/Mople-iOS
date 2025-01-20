//
//  PlanDetailViewController.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit

final class PlanDetailViewController: TitleNaviViewController, View, KeyboardResponsive {
    
    typealias Reactor = PlanDetailViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Handle KeyboardEvent
    var superView: UIView { self.view }
    var floatingView: UIView { textFieldStackview }
    var scrollView: UIScrollView { mainView }
    var floatingViewBottom: Constraint?
    
    // MARK: - Observable
    private var loadingObserver: PublishSubject<Bool> = .init()
    
    // MARK: - UI Components
    
    private let mainView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let planInfoView = PlanInfoView()
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.BG.secondary
        return view
    }()
    
    private(set) var commentContainer = UIView()
        
    private lazy var sendButton: BaseButton = {
        let btn = BaseButton()
        btn.setImage(image: .sendArrow,
                     imagePlacement: .all,
                     contentPadding: 0)
        btn.setBgColor(normalColor: ColorStyle.App.primary,
                       disabledColor: ColorStyle.Primary.disable)
        btn.setRadius(20)
        btn.isEnabled = false
        return btn
    }()
    
    private let textField: DefaultTextField = {
        let textField = DefaultTextField()
        textField.setPlaceholder("댓글을 입력해주세요")
//        textField.setInputTextField(view: <#T##UIView#>, mode: <#T##DefaultTextField.ViewMode#>)
        return textField
    }()
    
    private lazy var textFieldStackview: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [textField, sendButton])
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()

    init(title: String?,
         reactor: PlanDetailViewReactor) {
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
        setAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardEvent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObserver()
    }
    
    private func initalSetup() {
        setLayout()
        setNavi()
        setupKeyboardDismissGestrue()
    }
    
    private func setLayout() {
        self.view.addSubview(mainView)
        self.view.addSubview(textFieldStackview)
        mainView.addSubview(contentView)
        contentView.addSubview(planInfoView)
        contentView.addSubview(borderView)
        contentView.addSubview(commentContainer)

        mainView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(mainView.contentLayoutGuide)
            make.width.equalTo(mainView.frameLayoutGuide.snp.width)
        }
        
        planInfoView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(planInfoView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(8)
        }
        
        commentContainer.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
            
        textFieldStackview.snp.makeConstraints { make in
            make.top.equalTo(mainView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(56)
            floatingViewBottom = make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                .inset(UIScreen.getAdditionalBottomInset()).constraint
        }
        
        textField.snp.makeConstraints { make in
            make.height.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }
    
    private func setNavi() {
        self.naviBar.setBarItem(type: .left, image: .backArrow)
        self.naviBar.setBarItem(type: .right, image: .blackMenu)
    }
    
    func bind(reactor: PlanDetailViewReactor) {
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        Observable.combineLatest(viewDidLayout, reactor.pulse(\.$plan))
            .map({ $0.1 })
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, plan in
                vc.planInfoView.configure(with: .init(plan: plan))
            })
            .disposed(by: disposeBag)
        
        Observable.merge(reactor.pulse(\.$isLoading),
                         reactor.pulse(\.$isCommentLoading))
        .skip(1)
        .asDriver(onErrorJustReturn: false)
        .filter { [weak self] isLoad in
            self?.indicator.isAnimating == false && isLoad
        }
        .map { _ in true }
        .drive(self.rx.isLoading)
        .disposed(by: disposeBag)
        
        Observable.combineLatest(reactor.pulse(\.$isLoading),
                                 reactor.pulse(\.$isCommentLoading))
        .skip(1)
        .filter { isPlanInfoLoaded, isCommentLoaded  in
            isPlanInfoLoaded == false &&
            isCommentLoaded == false
        }
        .map { _ in false }
        .asDriver(onErrorJustReturn: false)
        .drive(self.rx.isLoading)
        .disposed(by: disposeBag)
    }
    
    private func setAction() {
        self.naviBar.leftItemEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.textField.rx.isEditMode
            .do(onNext: { print(#function, #line, "키보드 : \($0)" ) })
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isEditing in
                vc.handlePresentSendButton(isEditing)
            })
            .disposed(by: disposeBag)
        
        self.textField.rx.text
            .compactMap { $0 }
            .map { $0.count > 0 }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isEnabled in
                vc.sendButton.isEnabled = isEnabled
            })
            .disposed(by: disposeBag)
    }
    
    private func handlePresentSendButton(_ isEditing: Bool) {
        self.sendButton.isHidden = !isEditing
    }
}

extension PlanDetailViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func setupKeyboardDismissGestrue() {
        setupPanKeyboardDismiss()
        setupTapKeyboardDismiss()
    }
}

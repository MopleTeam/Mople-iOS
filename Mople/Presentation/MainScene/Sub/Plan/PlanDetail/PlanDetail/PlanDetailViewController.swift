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

final class PlanDetailViewController: TitleNaviViewController, View, ScrollKeyboardResponsive {
    
    
    typealias Reactor = PlanDetailViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Handle KeyboardEvent
    var floatingView: UIView { chatingTextFieldView }
    var floatingViewBottom: Constraint?
    var scrollView: UIScrollView { mainScrollView }
    var startOffsetY: CGFloat = .zero
    
    // MARK: - Observable
    private var loadingObserver: PublishSubject<Bool> = .init()
    
    // MARK: - UI Components
    
    private let mainScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let planInfoView = PlanInfoView()
    
    private(set) var photoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.Default.white
        view.isHidden = true
        return view
    }()
    
    private(set) var commentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.Default.white
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [planInfoView, photoContainer, commentContainer])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = ColorStyle.BG.secondary
        return sv
    }()
    
    private let chatingTextFieldView: ChatingTextFieldView = {
        let chatingView = ChatingTextFieldView()
        chatingView.backgroundColor = ColorStyle.Default.white
        return chatingView
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
        setScrollView()
        setupKeyboardDismissGestrue()
    }
    
    private func setLayout() {
        self.view.addSubview(mainScrollView)
        self.view.addSubview(chatingTextFieldView)
        mainScrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
    
        mainScrollView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
//            adjustableViewBottom = make.bottom.equalTo(self.view.safeAreaLayoutGuide)
//                .inset(UIScreen.getDefatulBottomInset() + 56).constraint
        }
        
        contentView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(mainScrollView.contentLayoutGuide)
            make.bottom.equalTo(mainScrollView.contentLayoutGuide)
            make.width.equalTo(mainScrollView.frameLayoutGuide.snp.width)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        chatingTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(mainScrollView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            floatingViewBottom = make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                .inset(UIScreen.getDefatulBottomInset()).constraint
        }
    }
    
    private func setScrollView() {
        self.mainScrollView.delegate = self
    }
    
    private func setNavi() {
        self.naviBar.setBarItem(type: .left, image: .backArrow)
        self.naviBar.setBarItem(type: .right, image: .blackMenu)
    }

    func bind(reactor: PlanDetailViewReactor) {
        outputBind(reactor: reactor)
        handleCommentCommand(reactor: reactor)
        handleParentChildLoading(reactor: reactor)
    }
    
    private func setAction() {
        self.naviBar.leftItemEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    public func showPhotoView() {
        photoContainer.isHidden = false
        self.photoContainer.snp.makeConstraints { make in
            make.height.equalTo(207)
        }
    }
}

// MARK: - Handle Reactor
extension PlanDetailViewController {
    private func outputBind(reactor: Reactor) {
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        Observable.combineLatest(viewDidLayout, reactor.pulse(\.$planInfo))
            .map({ $0.1 })
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, viewModel in
                vc.planInfoView.configure(with: viewModel)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleCommentCommand(reactor: Reactor) {
        let keyboardSended = chatingTextFieldView.rx.keyboardSendButtonTapped
        let buttonSended = chatingTextFieldView.rx.sendButtonTapped
        
        [keyboardSended, buttonSended].forEach {
            $0.map { comment in
                Reactor.Action.createComment(comment)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        }
        
        reactor.pulse(\.$createdComment)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, task in
                guard let _ = task else { return }
                vc.chatingTextFieldView.rx.text.onNext(nil)
                vc.mainScrollView.scrollToBottom(animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleParentChildLoading(reactor: Reactor) {
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
}

extension PlanDetailViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    private func setupKeyboardDismissGestrue() {
        setupTapKeyboardDismiss()
    }
}

extension PlanDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(#function, #line, "Path ")
        startOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(#function, #line, "Path ")
        startOffsetY = scrollView.contentOffset.y
    }
}

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
    
    // MARK: - Reactor
    typealias Reactor = PlanDetailViewReactor
    private var planDetailReactor: PlanDetailViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - Handle KeyboardEvent
    var keyboardHeight: CGFloat?
    var keyboardHeightDiff: CGFloat?
    var scrollView: UIScrollView? { commentListView?.tableView }
    var scrollViewHeight: CGFloat?
    var floatingView: UIView { chatingTextFieldView }
    var floatingViewBottom: Constraint?
    var startOffsetY: CGFloat = .zero
    
    // MARK: - Manager
    private let toastManager = ToastManager.shared
    
    // MARK: - Observable
    private let endFlow: PublishSubject<Void> = .init()
    private let editPost: PublishSubject<Void> = .init()
    private let deletePost: PublishSubject<Void> = .init()
    private let reportPost: PublishSubject<Void> = .init()
    private let cancleComment: PublishSubject<Void> = .init()
    
    // MARK: - Variables
    private var commonPlanModel: PlanDetailModel?
    
    // MARK: - UI Components
    private let planInfoView = PlanInfoView()
    
    private(set) var commentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.Default.white
        return view
    }()
    
    public var commentListView: CommentListViewController? {
        didSet {
            guard let commentListView else { return }
            commentListView.setHeaderView(planInfoView)
        }
    }
    
    private let chatingTextFieldView: ChatingTextFieldView = {
        let chatingView = ChatingTextFieldView()
        chatingView.backgroundColor = ColorStyle.Default.white
        return chatingView
    }()

    // MARK: - Life Cycle
    init(title: String?,
         reactor: PlanDetailViewReactor) {
        super.init(title: title)
        self.planDetailReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
        setNaviAction()
        setKeyboardControl()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewHeight()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setNavi()
        setLayout()
    }
    
    private func setLayout() {
        self.view.addSubview(commentContainer)
        self.view.addSubview(chatingTextFieldView)
        
        commentContainer.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
        }

        chatingTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(commentContainer.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            floatingViewBottom = make.bottom.equalToSuperview()
                .inset(UIScreen.getDefaultBottomPadding()).constraint
        }
    }
    
    private func setNavi() {
        print(#function, #line, "Path : #0412 ")
        self.naviBar.setBarItem(type: .left, image: .backArrow)
        self.naviBar.setBarItem(type: .right, image: .blackMenu)
    }
    
    // MARK: - Action
    private func setNaviAction() {
        self.naviBar.rightItemEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.handlePlanAction()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Setup
extension PlanDetailViewController {
    
    private func setReactor() {
        reactor = planDetailReactor
    }
    
    func bind(reactor: PlanDetailViewReactor) {
        inputBind(reactor: reactor)
        outputBind(reactor: reactor)
        handleCommentCommand(reactor: reactor)
        setNotification(reactor: reactor)
    }
    
    private func inputBind(reactor: Reactor) {
        Observable.just(())
            .map { Reactor.Action.fetchPlanInfo }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        planInfoView.rx.memberTapped
            .do(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .map { Reactor.Action.flow(.memberList) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        planInfoView.rx.mapTapped
            .do(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .map { Reactor.Action.flow(.placeDetailView) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editPost
            .map { Reactor.Action.flow(.editPost) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deletePost
            .map { Reactor.Action.deletePost }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reportPost
            .map { Reactor.Action.reportPost }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        cancleComment
            .map { Reactor.Action.parentCommand(.cancleEditing) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        naviBar.leftItemEvent
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        endFlow
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func outputBind(reactor: Reactor) {
        reactor.pulse(\.$planInfo)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, viewModel in
                print(#function, #line, "#0411 뷰 적용" )
                vc.planInfoView.configure(with: viewModel)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$commonPlanModel)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, model in
                vc.commonPlanModel = model
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$startOffsetY)
            .asDriver(onErrorJustReturn: .zero)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, offsetY in
                vc.setStartOffsetY(offsetY)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$reported)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, _ in
                vc.toastManager.presentToast(text: "신고 접수가 완료되었습니다")
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, err in
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleCommentCommand(reactor: Reactor) {
        let keyboardSended = chatingTextFieldView.rx.keyboardSendButtonTapped
        let buttonSended = chatingTextFieldView.rx.sendButtonTapped
        
        [keyboardSended, buttonSended].forEach {
            $0.map { comment in
                Reactor.Action.parentCommand(.writeComment(comment))
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        }
        
        reactor.pulse(\.$editComment)
            .skip(1)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, comment in
                vc.setEditComment(comment)
            })
            .disposed(by: disposeBag)
    }
    
    private func setNotification(reactor: Reactor) {
        EventService.shared.addPlanObservable()
            .filter({ [weak self] payload in
                self?.filterEdit(payload: payload) ?? false
            })
            .map { _ in Reactor.Action.updatePost }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        EventService.shared.addObservable(name: .postReview)
            .map { _ in Reactor.Action.updatePost }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func filterEdit<T>(payload: EventService.Payload<T>) -> Bool {
        switch payload {
        case .updated: return true
        default: return false
        }
    }
    
    // MARK: - Error Handling
    private func handleError(_ err: PlanDetailError) {
        switch err {
        case let .noResponse(err):
            alertManager.showResponseErrorMessage(err: err,
                                                 completion: { [weak self] in
                self?.endFlow.onNext(())
            })
        case let .midnight(err):
            alertManager.showDateErrorMessage(err: err,
                                              completion: { [weak self] in
                self?.endFlow.onNext(())
            })
        case .unknown:
            alertManager.showDefatulErrorMessage()
        }
    }
}

// MARK: - Helper
extension PlanDetailViewController {
    private func setEditComment(_ comment: String?) {
        print(#function, #line)
        let hasComment = comment != nil
        chatingTextFieldView.rx.text.onNext(comment)
        chatingTextFieldView.rx.isResign.onNext(!hasComment)
    }
    
    private func setStartOffsetY(_ offsetY: CGFloat) {
        guard let keyboardHeight else { return }
        self.startOffsetY = offsetY - keyboardHeight + UIScreen.getDefaultBottomPadding()
    }
}

// MARK: - 키보드 컨트롤
extension PlanDetailViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    
    var tapGestureShouldCancelTouchesInView: Bool { false }

    private func setKeyboardControl() {
        setupKeyboardEvent()
        setupTapKeyboardDismiss()
    }
        
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
    
    func dismissCompletion() {
        self.cancleComment.onNext(())
    }
}

extension PlanDetailViewController {
    
    // MARK: - 댓글 메뉴버튼 액션
    private func handlePlanAction() {
        guard let commonPlanModel else { return }
        if commonPlanModel.isCreator {
            showEditPlanAlert(type: commonPlanModel.type)
        } else {
            showReportPlanAlert(type: commonPlanModel.type)
        }
    }
    
    // MARK: - 작성자 본인인 경우(편집, 삭제)
    private func showEditPlanAlert(type: PlanDetailType) {
        var alertActions: [UIAlertAction] = []
        
        switch type {
        case .plan:
            alertActions = [editPlan(),
                            deletePlan()]
        case .review:
            alertActions = [editReview(),
                            deleteReview()]
        }

        alertManager.showActionSheet(actions: alertActions)
    }
    
    // MARK: - 일정 편집
    private func editPlan() -> UIAlertAction {
        return alertManager.makeAction(title: "일정 수정",
                                       completion: { [weak self] in
            self?.editPost.onNext(())
        })
    }
    
    private func deletePlan() -> UIAlertAction {
        return alertManager.makeAction(title: "일정 삭세",
                                       style: .destructive,
                                       completion: { [weak self] in
            self?.deletePost.onNext(())
        })
    }
    
    // MARK: - 후기 편집
    private func editReview() -> UIAlertAction {
        let hasImage = commonPlanModel?.hasImage ?? false
        let title = hasImage ? "후기 수정" : "후기 작성"
        
        return alertManager.makeAction(title: title,
                                       completion: { [weak self] in
            self?.editPost.onNext(())
        })
    }
    
    private func deleteReview() -> UIAlertAction {
        return alertManager.makeAction(title: "후기 삭세",
                                       style: .destructive,
                                       completion: { [weak self] in
            self?.deletePost.onNext(())
        })
    }
    
    // MARK: - 작성자가 아닌 경우(신고)
    private func showReportPlanAlert(type: PlanDetailType) {
        alertManager.showActionSheet(actions: [reportPlan(type: type)])
    }
    
    private func reportPlan(type: PlanDetailType) -> UIAlertAction {
        let title: String
        if case .plan = type {
            title = "일정 신고"
        } else {
            title = "후기 신고"
        }
        
        return alertManager.makeAction(title: title,
                                       style: .destructive,
                                       completion: { [weak self] in
            self?.reportPost.onNext(())
        })
    }
}

// MARK: - Helper
extension PlanDetailViewController {
    private func updateScrollViewHeight() {
        guard scrollViewHeight == nil else { return }
        self.scrollViewHeight = commentContainer.bounds.height
    }
}

//
//  PlanDetailViewController.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay
import ReactorKit

enum PostType {
    case plan
    case review
}

final class PostDetailViewController: TitleNaviViewController, View, ScrollKeyboardResponsive {
    
    // MARK: - Reactor
    typealias Reactor = PostDetailViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Handle KeyboardEvent
    var keyboardHeight: CGFloat?
    var keyboardHeightDiff: CGFloat?
    var scrollView: UIScrollView? { commentVC.tableView }
    var scrollViewHeight: CGFloat?
    var floatingView: UIView { chatingTextFieldView }
    var floatingViewBottom: Constraint?
    var startOffsetY: CGFloat = .zero
    
    // MARK: - Observable
    private let endFlow: PublishSubject<Void> = .init()
    private let participation: PublishSubject<Void> = .init()
    private let editPost: PublishSubject<Void> = .init()
    private let deletePost: PublishSubject<Void> = .init()
    private let reportPost: PublishSubject<Void> = .init()
    private let refreshPost: PublishSubject<Void> = .init()
    
    // MARK: - Variables
    private let postType: PostType
    private var postSummary: PostSummary?
    private var isEditMode: Bool = false
    
    // MARK: - UI Components
    private lazy var postInfoView: PostDetailView = {
        let view = PostDetailView(postType: postType)
        return view
    }()
    
    private let chatingTextFieldView: ChatingTextFieldView = {
        let chatingView = ChatingTextFieldView()
        chatingView.backgroundColor = .defaultWhite
        return chatingView
    }()
        
    // MARK: - CHild VC - Comment List
    private let commentVC: CommentListViewController
    private let commentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .defaultWhite
        return view
    }()
    
    private let mentionVC: MentionListViewController
    private let mentionContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .defaultWhite
        return view
    }()

    // MARK: - Life Cycle
    init(screenName: ScreenName,
         title: String?,
         postType: PostType,
         reactor: PostDetailViewReactor,
         commentVC: CommentListViewController,
         mentionVC: MentionListViewController) {
        self.postType = postType
        self.commentVC = commentVC
        self.mentionVC = mentionVC
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
        setAction()
        setKeyboardControl()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewHeight()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setNavi()
        setChildVC()
        setLayout()
    }
    
    private func setLayout() {
        self.view.addSubview(commentContainer)
//        self.view.addSubview(mentionContainer)
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
        
//        mentionContainer.snp.makeConstraints { make in
//            make.height.equalTo(180)
//            make.horizontalEdges.equalToSuperview().inset(20)
//            make.bottom.equalTo(chatingTextFieldView.snp.top).offset(-12)
//        }
    }
    
    private func setChildVC() {
        self.add(child: commentVC,
                 container: commentContainer)
        
        self.add(child: mentionVC,
                 container: mentionContainer)
    }
    
    private func setNavi() {
        self.naviBar.setBarItem(type: .left, image: .backArrow)
        self.naviBar.setBarItem(type: .right, image: .blackMenu)
    }
    
    private func setPostInfoView(with postSummary: PostSummary) {
        self.postSummary = postSummary
        postInfoView.configure(with: postSummary)
        commentVC.setHeaderView(postInfoView)
    }
    
    // MARK: - Action
    private func setAction() {
        setMenuAction()
        setParticipationAction()
        setCommentAction()
    }
}

// MARK: - Action
extension PostDetailViewController {
    // MARK: - Menu
    private func setMenuAction() {
        self.naviBar.rightItemEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.handlePostMenuAction()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - PlanInfo Action
    private func setParticipationAction() {
        guard postType == .plan else { return }
        
        postInfoView.rx.participationTapped
            .subscribe(with: self, onNext: { vc, isJoin in
                vc.handleParticipationPlan()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Comment Action
    private func setCommentAction() {
        chatingTextFieldView.rx.sendText
            .bind(with: self, onNext: { vc, text in
                vc.commentVC.rx.writeComment.onNext(text)
                vc.resetWriteMode()
            })
            .disposed(by: disposeBag)
        
        commentVC.rx.editComment
            .bind(with: self, onNext: { vc, comment in
                vc.setEditText(text: comment)
            })
            .disposed(by: disposeBag)
        
        commentVC.rx.offset
            .subscribe(with: self, onNext: { vc, offset in
                vc.setStartOffsetY(offset)
            })
            .disposed(by: disposeBag)
        
        commentVC.rx.refresh
            .bind(to: self.refreshPost)
            .disposed(by: disposeBag)
    }
    
    private func setEditText(text: String) {
        isEditMode = true
        chatingTextFieldView.textView.text = text
        chatingTextFieldView.textView.rx.isResign.onNext(false)
    }
    
    private func resetWriteMode() {
        self.view.endEditing(true)
        chatingTextFieldView.textView.text = nil
        isEditMode = false
    }
    
    private func setStartOffsetY(_ offsetY: CGFloat) {
        guard let keyboardHeight else { return }
        self.startOffsetY = offsetY - keyboardHeight + UIScreen.getDefaultBottomPadding()
    }
}

// MARK: - Reactor Setup
extension PostDetailViewController {

    func bind(reactor: PostDetailViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
        setNotification(reactor: reactor)
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
        editPost
            .map { Reactor.Action.flow(.editPost) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deletePost
            .map { Reactor.Action.post(.delete) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reportPost
            .map { Reactor.Action.post(.report) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        participation
            .map { Reactor.Action.post(.participation) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshPost
            .map { Reactor.Action.post(.refresh) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setFlowActionBind(_ reactor: Reactor) {
        naviBar.leftItemEvent
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        endFlow
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        postInfoView.rx.memberTapped
            .map { Reactor.Action.flow(.memberList) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        postInfoView.rx.mapTapped
            .map { Reactor.Action.flow(.placeDetailView) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setNotification(reactor: Reactor) {
        NotificationManager.shared.addPlanObservable()
            .compactMap {[weak self] payload -> Plan? in
                guard let self else { return nil }
                return filterUpdateType(payload: payload)
            }
            .map { Reactor.Action.update(.plan($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addReviewObservable()
            .compactMap {[weak self] payload -> Review? in
                guard let self else { return nil }
                return filterUpdateType(payload: payload)
            }
            .map { Reactor.Action.update(.review($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func filterUpdateType<T>(payload: NotificationManager.Payload<T>) -> T? {
        switch payload {
        case let .updated(item): return item
        default: return nil
        }
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$postSummary)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, postSummary in
                vc.commentVC.loadComment(with: postSummary.postId, totalCount: postSummary.commentCount)
                vc.setPostInfoView(with: postSummary)
                vc.showSuggestReviewAlert(with: postSummary)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$reported)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, _ in
                vc.toastManager.presentToast(text: L10n.Report.completed)
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
    
    // MARK: - Error Handling
    private func handleError(_ err: PlanDetailError) {
        switch err {
        case let .noResponse(err):
            alertManager.showResponseErrorMessage(err: err,
                                                 completion: { [weak self] in
                self?.endFlow.onNext(())
            })
        case .midnight:
            alertManager.showDateErrorMessage(err: DateTransitionError.midnightReset,
                                              completion: { [weak self] in
                self?.endFlow.onNext(())
            })
        default:
            alertManager.showDefatulErrorMessage()
        }
    }
}

// MARK: - Handle Plan Participation
extension PostDetailViewController {
    private func handleParticipationPlan() {
        guard let planSummary = postSummary as? PlanPostSummary else { return }
        
        if !planSummary.isParticipation {
            participation.onNext(())
        } else {
            showLeavePlanAlert()
        }
    }
    
    private func showLeavePlanAlert() {
        let createAction: DefaultAlertAction = .init(text: L10n.yes,
                                                     bgColor: .appSecondary,
                                                     completion: { [weak self] in
            self?.participation.onNext(())
        })
        
        alertManager.showDefaultAlert(title: L10n.Meetdetail.planLeaveInfo,
                                      defaultAction: .init(text: L10n.cancle,
                                                           textColor: .gray01,
                                                           bgColor: .appTertiary),
                                      addAction: [createAction])
    }
}

// MARK: - 키보드 컨트롤
extension PostDetailViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    
    private func setKeyboardControl() {
        setupKeyboardEvent()
        setupTapKeyboardDismiss()
    }
        
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: self.view)
        return !chatingTextFieldView.frame.contains(touchPoint)
    }
    
    func gestureCompletion() {
        cancleEditMode()
    }
    
    private func cancleEditMode() {
        guard isEditMode else { return }
        chatingTextFieldView.textView.text = nil
        isEditMode = false
        commentVC.changeWriteMode(.basic)
    }
}

// MARK: - Alert
extension PostDetailViewController {
    private func showSuggestReviewAlert(with postSummary: PostSummary) {
        guard postSummary.isCreator,
              let isReviewd = (postSummary as? ReviewPostSummary)?.isReviewd,
              !isReviewd else { return }
        
        let writeReview = writeReview()
        let cancleAction = cancleWriteReview()
        
        alertManager.showDefaultAlert(title: L10n.Review.suggestionInfo,
                                      subTitle: L10n.Review.suggestionSubinfo,
                                      defaultAction: cancleAction,
                                      addAction: [writeReview])
    }
    
    private func writeReview() -> DefaultAlertAction {
        return .init(text: L10n.Review.create,
                     textColor: .defaultWhite,
                     bgColor: .appPrimary,
                     completion: { [weak self] in
            self?.editPost.onNext(())
        })
    }
    
    private func cancleWriteReview() -> DefaultAlertAction {
        return .init(text: L10n.cancle,
                     textColor: .gray01,
                     bgColor: .appTertiary)
    }
}

// MARK: - Sheet
extension PostDetailViewController {
    
    // MARK: - 댓글 메뉴버튼 액션
    private func handlePostMenuAction() {
        let isCreator = postSummary?.isCreator ?? false
        if isCreator {
            showEditPostSheet()
        } else {
            showReportPostSheet()
        }
    }
    
    // MARK: - 작성자 본인인 경우(편집, 삭제)
    private func showEditPostSheet() {
        let editAction = editPostSheetAction()
        let deleteAction = deletePostSheetAction()
        sheetManager.showSheet(actions: [editAction, deleteAction])
    }
    
    // MARK: - 편집, 삭제 액션
    private func editPostSheetAction() -> DefaultSheetAction {
        let title = handlePostEditTitle()
        let image: UIImage? = postType == .plan ? .editPlan : .editReview
        return .init(text: title,
                     image: image,
                     completion: { [weak self] in
            self?.editPost.onNext(())
        })
    }
    
    private func handlePostEditTitle() -> String {
        switch postType {
        case .plan:
            return L10n.editPlan
        case .review:
            let hasImage = (postSummary as? ReviewPostSummary)?.hasImage ?? false
            return hasImage ? L10n.Review.edit : L10n.Review.create
        }
    }
    
    private func deletePostSheetAction() -> DefaultSheetAction {
        let title = postType == .plan
        ? L10n.Postdetail.deletePlan
        : L10n.Postdetail.deleteReview
        return .init(text: title,
                     image: .delete,
                     completion: { [weak self] in
            self?.deletePost.onNext(())
        })
    }

    
    // MARK: - 작성자가 아닌 경우(신고)
    private func showReportPostSheet() {
        let reportAction = reportPostSheetAction()
        sheetManager.showSheet(actions: [reportAction])
    }
    
    private func reportPostSheetAction() -> DefaultSheetAction {
        let title = postType == .plan ? L10n.Report.plan : L10n.Report.review
        
        return .init(text: title,
                     image: .report,
                     completion: { [weak self] in
            self?.reportPost.onNext(())
        })
    }
}

// MARK: - Helper
extension PostDetailViewController {
    private func updateScrollViewHeight() {
        guard scrollViewHeight == nil else { return }
        self.scrollViewHeight = commentContainer.bounds.height
    }
}


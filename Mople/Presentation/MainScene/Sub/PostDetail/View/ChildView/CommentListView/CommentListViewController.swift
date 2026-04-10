//
//  CommentListView.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import UIKit
import RxSwift
import RxRelay
import SnapKit
import ReactorKit
import RxDataSources

enum WriteMode {
    case edit(comment: Comment)
    case basic
}

final class CommentListViewController: TitleNaviViewController, View, ScrollKeyboardResponsive {
    
    // MARK: - Reactor
    typealias Reactor = CommentListViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Handle KeyboardEvent
    var keyboardHeight: CGFloat?
    var keyboardHeightDiff: CGFloat?
    var scrollView: UIScrollView? { tableView }
    var floatingView: UIView { chatingTextFieldView }
    var floatingViewBottom: Constraint?
    var startOffsetY: CGFloat = .zero
    
    // MARK: - Constraints
    private var mentionHeight: Constraint?
    private var cachedHeight: CGFloat?
    
    // MARK: - Variables
    private let type: CommentListType
    private var postId: Int?
    private var meetId: Int?
    private var writeMode: WriteMode = .basic
    private var comments: [Comment] = []
    private var totalCount: Int = 0
    
    // MARK: - Observable
    fileprivate let selectedPhoto: PublishSubject<Int> = .init()
    fileprivate let userProfileTap: PublishSubject<(name: String?, imagePath: String?)> = .init()
    fileprivate let writeComment: PublishSubject<(text: String, mentionIds: [Int])> = .init()
    private let likeComment: PublishSubject<Int> = .init()
    private let deleteComment: PublishSubject<Int> = .init()
    private let deletedComment: PublishSubject<Int> = .init()
    private let reportComment: PublishSubject<Int> = .init()
    private let fetchComment: PublishSubject<Int> = .init()
    private let fetchNextPage: PublishSubject<Void> = .init()
    private let reply: PublishSubject<Comment> = .init()

    
    // MARK: - UI Components
    private(set) var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .bgPrimary
        table.sectionFooterHeight = 0
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    private lazy var footerView: CommentListTableFooterView = {
        let view = CommentListTableFooterView(frame: .init(origin: .zero,
                                                           size: .init(width: tableView.bounds.width,
                                                                       height: 50)))
        return view
    }()
    
    private let chatingTextFieldView: ChatingTextFieldView = {
        let chatingView = ChatingTextFieldView()
        chatingView.backgroundColor = .bgPrimary
        return chatingView
    }()
    
    // MARK: - Child VC
    private let mentionVC: MentionListViewController
    private let mentionContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .bgPrimary
        view.setDynamicBorder(width: 1)
        view.layer.makeShadow(opactity: 0.1,           // Color의 10%
                              radius: 12,               // Blur 값
                              offset: CGSize(width: 0, height: 2),  // Position X: 0, Y: 2
                              color: UIColor.black)
        view.layer.cornerRadius = 12
        view.clipsToBounds = false
        return view
    }()
    
    
    // MARK: - Refresh Control
    fileprivate let refreshControl = UIRefreshControl()
    
    // MARK: - LifeCycle
    init(type: CommentListType,
         reactor: CommentListViewReactor,
         mentionVC: MentionListViewController) {
        self.mentionVC = mentionVC
        self.type = type
        super.init(title: "답글")
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setChildVC()
        setEdgeGesture()
        setKeyboardControl()
        setMentionBind()
        setNavi()
        setNaviItem()
    }

    // MARK: - UI Setup
    private func setNavi() {
        guard case .parent = reactor?.type else { return }
        self.hideTop(isHide: true)
    }
    
    private func setNaviItem() {
        guard case .child = reactor?.type else { return }
        self.setBarItem(type: .left)
    }
    
    private func setupUI() {
        setTableView()
        setLayout()
    }
    
    private func setTableView() {
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        tableView.register(CommentTableCell.self, forCellReuseIdentifier: CommentTableCell.reuseIdentifier)
        tableView.register(CommentSectionHeader.self, forHeaderFooterViewReuseIdentifier: CommentSectionHeader.reuseIdentifier)
    }
    
    private func setLayout() {
        self.view.addSubview(tableView)
        self.view.addSubview(chatingTextFieldView)
        self.view.addSubview(mentionContainer)
        

        tableView.snp.makeConstraints { make in
            if case .parent = reactor?.type {
                make.top.equalToSuperview()
            } else {
                make.top.equalTo(self.titleViewBottom)
            }
            make.horizontalEdges.equalToSuperview()
        }
        
        chatingTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            floatingViewBottom = make.bottom.equalToSuperview()
                .inset(UIScreen.getDefaultBottomPadding()).constraint
        }
        
        mentionContainer.snp.makeConstraints { make in
            mentionHeight = make.height.equalTo(0).constraint
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(chatingTextFieldView.snp.top).offset(-12)
        }
    }
    
    public func setHeaderView(_ headerView: UIView) {
        self.tableView.tableHeaderView = headerView
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.resizeHeaderView()
        }
    }
    
    // MARK: - Set ChildVC
    private func setChildVC() {
        self.add(child: mentionVC,
                 container: mentionContainer)
        mentionVC.view.layer.cornerRadius = 12
        mentionVC.view.clipsToBounds = true
    }
    
    // MARK: - Gesture
    private func setEdgeGesture() {
        guard let currentNavi = self.findCurrentNavigation(),
              let appNavi = currentNavi as? AppNaviViewController,
              case .parent = reactor?.type else { return }
        tableView.panGestureRecognizer.require(toFail: appNavi.edgeGesture)
    }
    
    private func setMentionBind() {
        chatingTextFieldView.rx.sendMessage
            .bind(with: self, onNext: { vc, info in
                vc.writeComment.onNext((info.text, info.mentionList))
            })
            .disposed(by: disposeBag)
        
        chatingTextFieldView.textView.rx.mention
            .bind(with: self, onNext: { vc, keyword in
                if let keyword {
                    vc.showMentionVC(keyword: keyword)
                } else {
                    vc.hideMentionVC()
                }
            })
            .disposed(by: disposeBag)
        
        mentionVC.rx.selectedMention
            .bind(with: self, onNext: { vc, memberInfo in
                guard let name = memberInfo.nickname,
                      let id = memberInfo.memberId else { return }
                vc.chatingTextFieldView.textView.addMention(text: name,
                                                            id: id)
            })
            .disposed(by: disposeBag)
        
        mentionVC.rx.height
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self, onNext: { vc, height in
                vc.mentionHeight?.update(offset: height)
            })
            .disposed(by: disposeBag)
    }
    
    private func showMentionVC(keyword: String) {
        switch type {
        case .parent:
            guard let meetId else { return }
            mentionVC.searchMention(meetId: meetId, keyword: keyword)
        case let .child(_, meetId):
            mentionVC.searchMention(meetId: meetId, keyword: keyword)
        }
    }
    
    private func hideMentionVC() {
        mentionHeight?.update(offset: 0)
    }
}

// MARK: - Handle Comment
extension CommentListViewController {
    public func loadComment(with postId: Int?,
                            meetId: Int?,
                            totalCount: Int) {
        self.meetId = meetId
        self.postId = postId
        self.totalCount = totalCount
        changeWriteMode(.basic)
        guard let postId else { return }
        fetchComment.onNext(postId)
    }
    
    public func changeWriteMode(_ mode: WriteMode) {
        writeMode = mode
        switch mode {
        case .edit(let comment):
            setEditComment(comment)
        case .basic:
            setStartMessage()
        }
    }
    
    private func setStartMessage() {
        chatingTextFieldView.textView.text = nil
        chatingTextFieldView.hideEditLabel(isHide: true)
    }
    
    private func setEditComment(_ comment: Comment) {
        guard let text = comment.comment else { return }
        chatingTextFieldView.hideEditLabel(isHide: false)
        chatingTextFieldView.textView.setMessage(text: text, mentions: comment.mentions)
        chatingTextFieldView.textView.rx.isResign.onNext(false)
    }
}

// MARK: - Reactor Setup
extension CommentListViewController {
    
    func bind(reactor: CommentListViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
    }

    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }

    private func setActionBind(_ reactor: Reactor) {
        self.naviBar.leftItemEvent
            .map { Reactor.Action.endFlow }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        fetchComment
            .map { [weak self] in
                let isRefresh = self?.refreshControl.isRefreshing == true
                return Reactor.Action.fetchPage(postId: $0,
                                                   isRefresh: isRefresh)
            }
            .compactMap({ $0 })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        fetchNextPage
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.fetchNextPage }
            .compactMap({ $0 })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        writeComment
            .observe(on: MainScheduler.asyncInstance)
            .compactMap({ self.handleWriteComment(text: $0.text,
                                        mentionIds: $0.mentionIds) })
            .do(onNext: { _ in
                self.changeWriteMode(.basic)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteComment
            .map { Reactor.Action.deleteComment(id: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deletedComment
            .map { Reactor.Action.deletedComment(id: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        likeComment
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.likeComment(id: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reportComment
            .map { Reactor.Action.reportComment(id: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        userProfileTap
            .map { Reactor.Action.showWriterImage(name: $0.name, imagePath: $0.imagePath) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reply
            .compactMap({
                guard let meetId = self.meetId else { return nil }
                return Reactor.Action.showReply(parentComment: $0, meetId: meetId)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setParentCommentCell(comment: Comment,
                                      index: Int,
                                      cell: CommentTableCell) {
        let isLast = isLastCell(at: index)
        if comment.isMockup {
            cell.mockParentConfigure(isLastCell: isLast)
        } else {
            cell.parentCommentConfigure(with: comment, isLastCell: isLast)
        }
        
        cell.replyTapped = { [weak self] in
            guard let postId = self?.postId else { return }
            var newItem = comment
            newItem.updatePostId(postId: postId)
            self?.reply.onNext(newItem)
        }
    }
    
    private func setChildCommentCell(comment: Comment, cell: CommentTableCell) {
        if comment.isMockup {
            cell.mockChildConfigure()
        } else {
            cell.childCommentConfigure(with: comment)
        }
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$comments)
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { self.comments = $0 })
            .drive(self.tableView.rx.items(cellIdentifier: CommentTableCell.reuseIdentifier,
                                           cellType: CommentTableCell.self)) { [weak self] index, item, cell in
                guard let self else { return }
                switch reactor.type {
                case .parent:
                    setParentCommentCell(comment: item, index: index, cell: cell)
                case .child:
                    setChildCommentCell(comment: item, cell: cell)
                }
                
                cell.profileTapped = { [weak self] in
                    self?.userProfileTap.onNext((item.writerName,
                                                 item.writerThumbnailPath))
                }
                
                cell.menuTapped = { [weak self] in
                    self?.handleCommentAction(with: item)
                }
                
                cell.likeTapped = { [weak self] in
                    guard let id = item.id else { return }
                    self?.likeComment.onNext(id)
                }
                
                cell.onAppearPreview = { [weak self] in
                    UIView.performWithoutAnimation {
                        self?.tableView.beginUpdates()
                        self?.tableView.endUpdates()
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // 댓글 추가/삭제 시 총 댓글 수 업데이트
        reactor.pulse(\.$adjustCommentCount)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, increment in
                vc.totalCount += increment ? 1 : -1
            })
            .disposed(by: disposeBag)

        reactor.pulse(\.$reportedComment)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, _ in
                vc.toastManager.presentToast(text: L10n.Report.completed)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$loadState)
            .skip(1)
            .asDriver(onErrorJustReturn: (false, .none))
            .drive(with: self, onNext: { vc, loadState in
                vc.handleLoadingType(isLoad: loadState.isLoad,
                                     mode: loadState.mode)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, err in
            })
            .disposed(by: disposeBag)
    }
    
    private func handleWriteComment(text: String, mentionIds: [Int]) -> Reactor.Action? {
        switch writeMode {
        case .basic:
            return .createComment(content: text,
                                  mentions: mentionIds)
        case let .edit(comment):
            guard let id = comment.id else { return nil }
            return .editComment(id: id, content: text, mentions: mentionIds)
        }
    }
}

extension CommentListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return comments[indexPath.row].isMockup ? 100 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let reactor else { return 0 }
        switch reactor.type {
        case .parent: return 58
        case .child: return 28
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard case .parent = reactor?.type else { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: CommentSectionHeader.reuseIdentifier) as! CommentSectionHeader
        view.updateCount(totalCount)
        print(#function, #line, "Path : # 헤더 업데이트 ")
        return view
    }

    // MARK: - ScrollView Deleagte
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setStartOffsetY(scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setStartOffsetY(scrollView.contentOffset.y)
    }
    
    private func setStartOffsetY(_ offsetY: CGFloat) {
        guard let keyboardHeight else { return }
        self.startOffsetY = offsetY - keyboardHeight + UIScreen.getDefaultBottomPadding()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottom(threshold: 50),
           self.reactor?.page?.hasNext == true {
            fetchNextPage.onNext(())
        }
    }
}

// MARK: - Alert
extension CommentListViewController {
    
    // MARK: - 댓글 메뉴버튼 액션
    private func handleCommentAction(with comment: Comment) {
        if comment.isWriter {
            showEditCommentAlert(with: comment)
        } else {
            showReportCommentAlert(with: comment)
        }
    }
    
    // MARK: - 작성자 본인인 경우(편집, 삭제)
    private func showEditCommentAlert(with comment: Comment) {
        let editComment = editCommentAction(with: comment)
        let deleteComment = deleteCommentAction(with: comment)
        sheetManager.showSheet(actions: [editComment,
                                         deleteComment])
    }
    
    private func editCommentAction(with comment: Comment) -> DefaultSheetAction {
        return .init(text: L10n.Comment.edit,
                     image: .editComment,
                     completion: { [weak self] in
            self?.changeWriteMode(.edit(comment: comment))
        })
    }
    
    private func deleteCommentAction(with comment: Comment) -> DefaultSheetAction {
        return .init(text: L10n.Comment.delete,
                     image: .delete,
                     completion: { [weak self] in
            guard let id = comment.id else { return }
            self?.deleteComment.onNext(id)
        })
    }
    
    // MARK: - 작성자가 아닌 경우(신고)
    private func showReportCommentAlert(with comment: Comment) {
        guard let id = comment.id else { return }
        let reportComment = reportCommentAction(id: id)
        sheetManager.showSheet(actions: [reportComment])
    }
    
    private func reportCommentAction(id: Int) -> DefaultSheetAction {
        return .init(text: L10n.Report.comment,
                     image: .report,
                     completion: { [weak self] in
            self?.reportComment.onNext(id)
        })
    }
}

// MARK: - Helper
extension CommentListViewController {
    private func isLastCell(at index: Int) -> Bool {
        guard let commentsCount = reactor?.currentState.comments.count else { return false }
        return commentsCount == (index + 1)
    }
    
    public func deletedComment(id: Int) {
        deletedComment.onNext(id)
    }
}

// MARK: - Handle Loading
extension CommentListViewController {
    private func handleLoadingType(isLoad: Bool, mode: LoadMode) {
        switch mode {
        case .edit:
            self.rx.isLoading.onNext(isLoad)
        case .refresh:
            refreshControl.endRefreshing()
        case .more:
            footerView.setLoading(isLoad)
            tableView.tableFooterView = footerView
        default:
            break
        }
    }
}

extension CommentListViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    var tapGestureShouldCancelTouchesInView: Bool { false }

    private func setKeyboardControl() {
        setupKeyboardEvent(showCompletion: { [weak self] in
            guard let self,
                  let cachedHeight else { return }
            mentionHeight?.update(offset: cachedHeight)
        }, hideCompletion: { [weak self] in
            guard let self else { return }
            cachedHeight = mentionContainer.frame.height
            mentionHeight?.update(offset: 0)
        })
        setupTapKeyboardDismiss()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: self.view)
        let isTextViewTouch = chatingTextFieldView.frame.contains(touchPoint)
        let isMentionTouch = mentionContainer.frame.contains(touchPoint)
        return !isTextViewTouch && !isMentionTouch
    }

    func gestureCompletion() {
        cancleEditMode()
    }

    private func cancleEditMode() {
        guard case .edit = writeMode else { return }
        changeWriteMode(.basic)
    }
}

extension Reactive where Base: CommentListViewController {
    var refresh: Observable<Void> {
        return base.refreshControl.rx.controlEvent(.valueChanged)
            .filter { base.refreshControl.isRefreshing }
    }
}




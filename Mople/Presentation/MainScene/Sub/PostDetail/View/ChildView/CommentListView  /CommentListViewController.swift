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
    case edit(commentId: Int)
    case reply(parentId: Int)
    case basic
}

final class CommentListViewController: DefaultViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = CommentListViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private var postId: Int?
    private var writeMode: WriteMode = .basic
    private var comments: [Comment] = []
    private var page: PageInfo?
    private var totalCount: Int = 0 {
        didSet {
            self.updateCommentCount(totalCount)
        }
    }
    
    // MARK: - Observable
    fileprivate let offset: PublishSubject<CGFloat> = .init()
    fileprivate let selectedPhoto: PublishSubject<Int> = .init()
    fileprivate let userProfileTap: PublishSubject<(name: String?, imagePath: String?)> = .init()
    fileprivate let writeComment: PublishSubject<String> = .init()
    fileprivate let editingComment: PublishSubject<String> = .init()
    private let likeComment: PublishSubject<Int> = .init()
    private let deleteComment: PublishSubject<Int> = .init()
    private let reportComment: PublishSubject<Int> = .init()
    private let fetchComment: PublishSubject<Int> = .init()
    private let fetchNextPage: PublishSubject<String> = .init()
    private let loadReplyComment: PublishSubject<(Int, cursor: String?)> = .init()
    private let cachingReply: PublishSubject<(Int, CommentPage)> = .init()

    
    // MARK: - UI Components
    private(set) var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .defaultWhite
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
    
    // MARK: - Refresh Control
    fileprivate let refreshControl = UIRefreshControl()
    
    // MARK: - LifeCycle
    init(reactor: CommentListViewReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setEdgeGesture()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setTableView()
        setLayout()
    }
    
    private func setTableView() {
        tableView.refreshControl = refreshControl
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CommentTableCell.self, forCellReuseIdentifier: CommentTableCell.reuseIdentifier)
        tableView.register(CommentSectionHeader.self, forHeaderFooterViewReuseIdentifier: CommentSectionHeader.reuseIdentifier)
    }
    
    private func setLayout() {
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func setHeaderView(_ headerView: UIView) {
        self.tableView.tableHeaderView = headerView
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.resizeHeaderView()
        }
    }
    
    // MARK: - Gesture
    private func setEdgeGesture() {
        guard let currentNavi = self.findCurrentNavigation(),
              let appNavi = currentNavi as? AppNaviViewController else { return }
        tableView.panGestureRecognizer.require(toFail: appNavi.edgeGesture)
    }
}

// MARK: - Handle Comment
extension CommentListViewController {
    public func loadComment(with postId: Int?, totalCount: Int) {
        guard let postId else { return }
        resetData()
        self.postId = postId
        self.totalCount = totalCount
        fetchComment.onNext(postId)
    }
    
    private func resetData() {
        changeWriteMode(.basic)
        self.page = nil
    }
    
    public func changeWriteMode(_ mode: WriteMode) {
        writeMode = mode
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
            .map { Reactor.Action.fetchNextPage(nextCursor: $0) }
            .compactMap({ $0 })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        writeComment
            .observe(on: MainScheduler.asyncInstance)
            .compactMap({ [weak self] in self?.handleWriteComment($0) })
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteComment
            .map { Reactor.Action.deleteComment(id: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        likeComment
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
        
        loadReplyComment
            .map { Reactor.Action.fetchReplyComment(parentId: $0.0, cursor: $0.1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        cachingReply
            .map { Reactor.Action.cachingReply(parentId: $0.0,
                                               replyPage: $0.1)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$fetchedPage)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, page in
                vc.addPage(commentPage: page)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$fetchedReplyComment)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, result in
                vc.addReplyPage(parentId: result.parentId,
                            commentPage: result.page)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$addedComment)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, comment in
                vc.changeWriteMode(.basic)
                vc.replaceAddedComment(comment: comment)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$editedComment)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, comment in
                vc.changeWriteMode(.basic)
                vc.replaceEditedComment(comment: comment)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$deletedCommentId)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, id in
                vc.handleDeleteComment(id)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$reportedComment)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, _ in
                vc.toastManager.presentToast(text: L10n.Report.completed)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isUiLoading)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
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
    
    private func handleWriteComment(_ text: String) -> Reactor.Action {
        switch writeMode {
        case .basic:
            addMockComment()
            return .createComment(content: text,
                                  mentions: [])
        case let .reply(parentId):
            addMockReply(parentId: parentId)
            return .createReply(parentId: parentId,
                                content: text,
                                mentions: [])
        case let .edit(id):
            updateCellLoading(commentId: id)
            return .editComment(id: id, content: text, mentions: [])
        }
    }
    
    private func handleDeleteComment(_ id: Int) {
        guard let comment = findItem(id: id) else { return }
        switch comment.type {
        case .parent: deleteComment(with: id)
        case .child: deleteReply(with: comment)
        }
    }
}

// MARK: - Handle Comment
extension CommentListViewController {

    private func addPage(commentPage: CommentPage) {
        let isFirst = self.page == nil
        self.page = commentPage.page
        if isFirst {
            self.comments = commentPage.content
        } else {
            self.comments.append(contentsOf: commentPage.content)
        }
        tableView.reloadData()
    }
    
    private func addComment(comment: Comment) {
        self.comments.insert(comment, at: 0)
        self.tableView.insertRows(at: [.init(row: 0, section: 0)], with: .top)
    }

    private func deleteComment(with id: Int) {
        var count: Int = 0
        comments.removeAll {
            if $0.id == id || $0.parentId == id {
                count += 1
                return true
            } else {
                return false
            }
        }
        totalCount -= count
        tableView.reloadData()
    }
}

// MARK: - Handle Reply
extension CommentListViewController {
    private func addReplyPage(parentId: Int, commentPage: CommentPage) {
        guard let page = commentPage.page else { return }
        updateReplyPage(parentId: parentId, page: page)
        setReply(parentId: parentId, replys: commentPage.content)
    }
    
    private func updateReplyPage(parentId: Int, page: PageInfo) {
        guard let parentIndex = findItemIndex(id: parentId) else { return }
        comments[parentIndex].replyPage = page
        comments[parentIndex].loadReplyCount += page.size
    }
    
    private func setReply(parentId: Int, replys: [Comment]) {
        guard let parentIndex = findItemIndex(id: parentId) else { return }
        let lastReplyIndex = findLastReplyIndex(parentId: parentId)
        let headIndex = lastReplyIndex ?? parentIndex
        insertReply(headIndex: headIndex, replys: replys)
    }
    
    private func addReply(parentId: Int, reply: Comment) {
        guard let parentIndex = findItemIndex(id: parentId) else { return }
        comments[parentIndex].loadReplyCount += 1
        comments[parentIndex].replyCount += 1
        setReply(parentId: parentId, replys: [reply])
    }
    
    private func insertReply(headIndex: Int,
                             replys: [Comment]) {
        guard replys.count > 0 else { return }
        
        comments.insert(contentsOf: replys, at: headIndex + 1)
        tableView.performBatchUpdates {
            let insertIndexPahts = getNewReplyIndexPath(headIndex: headIndex, replyCount: replys.count)
            tableView.insertRows(at: insertIndexPahts, with: .top)
            tableView.reloadRows(at: [.init(row: headIndex, section: 0)], with: .none)
        }
    }
    
    private func deleteReply(with reply: Comment) {
        guard let id = reply.id,
              let parentId = reply.parentId,
              let parentIndex = findItemIndex(id: parentId) else { return }
        comments[parentIndex].replyCount -= 1
        comments[parentIndex].loadReplyCount -= 1
        comments.removeAll { $0.id == id }
        totalCount -= 1
        tableView.reloadData()
    }

    // MARK: - 대댓글 숨기기
    private func hideReplies(parentId: Int) {
        guard let parentIndex = findItemIndex(id: parentId) else { return }
        cachingReplyPage(parentId: parentId, parentIndex: parentIndex)
        handleDeleteReplies(parentId: parentId,
                     parentIndex: parentIndex)
    }
    
    /// 대댓글 캐시 데이터 저장
    private func cachingReplyPage(parentId: Int, parentIndex: Int) {
        setCacheReplyPage(commentIndex: parentIndex)
        let replyCount = comments[parentIndex].replyCount
        let replys = getUniqueReplys(parentId: parentId)
        let replyPage = CommentPage(content: Array(replys),
                                    page: .init(nextCursor: nil,
                                                hasNext: false,
                                                size: replyCount))
        cachingReply.onNext((parentId, replyPage))
    }
    
    /// 댓글데이터 대댓글 캐싱 설정
    private func setCacheReplyPage(commentIndex: Int) {
        comments[commentIndex].loadReplyCount = 0
        comments[commentIndex].replyPage = nil
        comments[commentIndex].hasCachingReply = true
    }
    
    /// 숨길 대댓글 삭제 처리
    private func handleDeleteReplies(parentId: Int,
                                     parentIndex: Int) {
        let isVisibleComment = isVisibleCell(at: .init(row: parentIndex, section: 0))
        let canDeleteRows = shouldDeleteReplyRows(parentId: parentId)
        
        if isVisibleComment || !canDeleteRows {
            deleteReplies(parentId: parentId,
                          parentIndex: parentIndex,
                          canAnimation: canDeleteRows)
        } else {
            self.deleteReplies(parentId: parentId)
            self.tableView.reloadData()
        }
    }
    
    private func deleteReplies(parentId: Int,
                               parentIndex: Int,
                               canAnimation: Bool) {
        guard let comment = findItem(id: parentId) else { return }
        let deleteIndexPaths = getReplyIndexPath(parentId: parentId)
        let isLastComment = isLastComment(id: parentId)
        self.updateHeadCellNonAnimation(at: parentIndex,
                                        state: .loadMore(comment.replyCount),
                                        hasBorder: !isLastComment,
                                        completion: {
            self.deleteReplies(parentId: parentId)
            self.tableView.deleteRows(at: deleteIndexPaths, with: canAnimation ? .top : .none)
        })
    }
    
    private func shouldDeleteReplyRows(parentId: Int) -> Bool {
        let deleteIndexPaths = getReplyIndexPath(parentId: parentId)
        let deleteCellsHeight = calculateCellsHeight(with: deleteIndexPaths)
        let remainScrollHeight = remainScrollHeight()
        return (remainScrollHeight - deleteCellsHeight) > 0
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

// MARK: - Cell Loading
extension CommentListViewController {
    
    // MARK: - 로딩 셀 추가
    /// 댓글 로딩 데이터 추가
    private func addMockComment() {
        let mockComment = Comment.mockComment()
        addComment(comment: mockComment)
    }
    
    /// 대댓글 로딩 데이터 추가
    private func addMockReply(parentId: Int) {
        let mockReply = Comment.mockComment(parentId: parentId)
        addReply(parentId: parentId, reply: mockReply)
    }
    
    /// 추가된 댓글 교체
    private func replaceAddedComment(comment: Comment) {
        guard let index = findMockItemIndex() else { return }
        totalCount += 1
        comments[index] = comment
        tableView.reloadRows(at: [.init(row: index, section: 0)], with: .none)
    }
    
    // MARK: - 셀 로딩 변경
    /// 수정 댓글 로딩
    private func updateCellLoading(commentId: Int) {
        guard let index = findItemIndex(id: commentId) else { return }
        comments[index].isMockup = true
        let cell = tableView.cellForRow(at: .init(row: index, section: 0)) as? CommentTableCell
        cell?.setClearIndicator(isLoad: true)
    }
    
    /// 수정된 댓글 교체
    private func replaceEditedComment(comment: Comment) {
        guard let id = comment.id,
              let index = findItemIndex(id: id) else { return }
        comments[index].replaceComment(comment)
        tableView.reloadRows(at: [.init(row: index, section: 0)], with: .none)
    }
}

// MARK: - Comment Helper
extension CommentListViewController {
    private func isLastItem(id: Int) -> Bool {
        return comments.last?.id == id
    }
    
    private func isLastComment(id: Int) -> Bool {
        guard let lastComment = comments.filter({ $0.type == .parent }).last else { return false }
        return lastComment.id == id
    }
    
    private func isLastReply(parentId: Int, reply: Comment) -> Bool {
        guard let lastReply = findLastReply(parentId: parentId)  else { return false }
        return reply.uuid == lastReply.uuid
    }
    
    private func findItem(id: Int) -> Comment? {
        return comments.first { $0.id == id }
    }
    
    private func findLastReply(parentId: Int) -> Comment? {
        return comments.filter({ $0.parentId == parentId }).last
    }
    
    private func findItemIndex(id: Int) -> Int? {
        return comments.firstIndex(where: { $0.id == id })
    }
    
    private func findMockItemIndex() -> Int? {
        return comments.firstIndex { $0.isMockup == true}
    }
    
    private func findLastReplyIndex(parentId: Int) -> Int? {
        guard let lastReply = findLastReply(parentId: parentId),
              let id = lastReply.id else { return nil }
        return findItemIndex(id: id)
    }
    
    private func deleteReplies(parentId: Int) {
        comments.removeAll { $0.parentId == parentId }
    }
    
    private func getUniqueReplys(parentId: Int) -> [Comment] {
        return comments
            .filter { $0.parentId == parentId }
            .reduce(into: [Comment]()) { partialResult, reply in
                guard !partialResult.contains(where: { $0.id == reply.id }) else { return }
                partialResult.append(reply)
            }
            .sorted()
    }
}

// MARK: - Cell Helper
extension CommentListViewController {
    
    private func isVisibleCell(at indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath)
        return tableView.visibleCells.contains { $0 == cell }
    }
        
    private func getReplyIndexPath(parentId: Int) -> [IndexPath] {
        guard let firstIndex = comments.firstIndex(where: { $0.parentId == parentId }),
              let lastIndex = comments.lastIndex(where: { $0.parentId == parentId }) else { return [] }
        return Array(firstIndex...lastIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    private func getNewReplyIndexPath(headIndex: Int, replyCount: Int) -> [IndexPath] {
        let startIndex = headIndex + 1
        let endIndex = startIndex + (replyCount - 1)
        return Array(startIndex...endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    private func findCommentCell(with comment: Comment) -> CommentTableCell? {
        guard let id = comment.id,
              let index = findItemIndex(id: id) else { return nil }
        return tableView.cellForRow(at: .init(row: index, section: 0)) as? CommentTableCell
    }
}

extension CommentListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableCell.reuseIdentifier,
                                                 for: indexPath) as! CommentTableCell
        let item = comments[indexPath.row]
        
        configureCell(with: item,
                      cell: cell)
        
        cell.menuTapped = { [weak self] in
            self?.handleCommentAction(with: item)
        }
        
        cell.likeTapped = { [weak self] id in
            self?.likeComment.onNext(id)
        }
        
        cell.moreReply = { [weak self] id in
            let replyNextCursor = self?.findItem(id: id)?.replyPage?.nextCursor
            self?.loadReplyComment.onNext((id, replyNextCursor))
        }
        
        cell.hideReply = { [weak self] id in
            self?.hideReplies(parentId: id)
        }
        
        cell.replyTapped = { [weak self] id in
            self?.changeWriteMode(.reply(parentId: id))
        }
        
        return cell
    }
    
    // MARK: - Cell Configure
    private func configureCell(with comment: Comment, cell: CommentTableCell) {
        if comment.isMockup {
            cell.mockConfigure()
        } else {
            handleCommentTypeCell(with: comment, cell: cell)
        }
    }
    
    private func handleCommentTypeCell(with comment: Comment, cell: CommentTableCell) {
        guard let id = comment.id else { return }
        switch comment.type {
        case .child:
            guard let parentId = comment.parentId,
                  let parentComment = comments.first(where: { $0.id == parentId }) else { break }
            cell.configure(with: .reply(parent: parentComment,
                                        reply: comment,
                                        isLastReply: isLastReply(parentId: parentId,
                                                                 reply: comment),
                                        isLastCell: isLastItem(id: id)))
        case .parent:
            cell.configure(with: .comment(comment,
                                          isLastCell: isLastComment(id: id)))
        }
    }
    
    // MARK: - Cell Update
    private func updateHeadCell(at headIndex: Int,
                                   state: BottomButtonState,
                                   hasBorder: Bool) {
        let headComment = comments[headIndex]
        guard let cell = findCommentCell(with: headComment) else { return }
        cell.configureBottomButton(with: state)
        cell.setBorderLine(hasBorder: hasBorder)
    }
    
    private func updateHeadCellNonAnimation(at headIndex: Int,
                                            state: BottomButtonState,
                                            hasBorder: Bool,
                                            completion: (() -> Void)? = nil) {
        UIView.performWithoutAnimation {
            tableView.performBatchUpdates {
                updateHeadCell(at: headIndex,
                               state: state,
                               hasBorder: hasBorder)
            }
        }
        
        DispatchQueue.main.async {
            completion?()
        }
    }
}

extension CommentListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return comments[indexPath.row].isMockup ? 100 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: CommentSectionHeader.reuseIdentifier) as! CommentSectionHeader
        return view
    }
    
    private func updateCommentCount(_ count: Int) {
        let sectionHeader = tableView.headerView(forSection: 0) as? CommentSectionHeader
        sectionHeader?.updateCount(count)
    }

    // MARK: - ScrollView Deleagte
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        offset.onNext(scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        offset.onNext(scrollView.contentOffset.y)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottom(threshold: 200),
           let nextCursor = self.page?.nextCursor {
            fetchNextPage.onNext(nextCursor)
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
                                         deleteComment],
                               cancleAction: { [weak self] in
            self?.changeWriteMode(.basic)
        })
    }
    
    private func editCommentAction(with comment: Comment) -> DefaultSheetAction {
        return .init(text: L10n.Comment.edit,
                     image: .editComment,
                     completion: { [weak self] in
            guard let id = comment.id,
                  let text = comment.comment else { return }
            self?.changeWriteMode(.edit(commentId: id))
            self?.editingComment.onNext(text)
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
    /// 특정 셀 사이즈 구하기
    private func calculateCellsHeight(with indexPath: [IndexPath]) -> CGFloat {
        return indexPath
            .map { tableView.rectForRow(at: $0).height }
            .reduce(0, +)
    }
    
    private func remainScrollHeight() -> CGFloat {
        let contentHeight = tableView.contentSize.height
        let currentOffsetY = tableView.contentOffset.y
        let boundsHeight = tableView.bounds.height
        return contentHeight - (currentOffsetY + boundsHeight)
    }
}


extension Reactive where Base: CommentListViewController {
    var writeComment: AnyObserver<String> {
        return base.writeComment
            .asObserver()
    }
    
    var editComment: Observable<String> {
        return base.editingComment
    }
    
    var offset: Observable<CGFloat> {
        return base.offset
    }
    
    var refresh: Observable<Void> {
        return base.refreshControl.rx.controlEvent(.valueChanged)
            .filter { base.refreshControl.isRefreshing }
    }
}








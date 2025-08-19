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
    private let fetchNextPage: PublishSubject<Void> = .init()

    
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
    public func loadComment(with postId: Int?,
                            totalCount: Int) {
        guard let postId else { return }
        self.postId = postId
        self.totalCount = totalCount
        changeWriteMode(.basic)
        fetchComment.onNext(postId)
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
            .map { Reactor.Action.fetchNextPage }
            .compactMap({ $0 })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        writeComment
            .observe(on: MainScheduler.asyncInstance)
            .compactMap({ [weak self] in self?.handleWriteComment($0) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteComment
            .map { Reactor.Action.deleteComment(id: $0) }
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
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$comments)
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { self.comments = $0 })
            .drive(self.tableView.rx.items(cellIdentifier: CommentTableCell.reuseIdentifier,
                                           cellType: CommentTableCell.self)) { [weak self] index, item, cell in
                guard let self, let commentId = item.id else { return }
                let isLast = isLastCell(at: index)
                if item.isMockup {
                    cell.mockConfigure()
                } else {
                    cell.configure(with: item, isLastCell: isLast)
                }
                
                cell.menuTapped = { [weak self] in
                    self?.handleCommentAction(with: item)
                }
                
                cell.likeTapped = { [weak self] in
                    self?.likeComment.onNext(commentId)
                }
            }
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
    
    private func handleWriteComment(_ text: String) -> Reactor.Action {
        switch writeMode {
        case .basic:
            return .createComment(content: text,
                                  mentions: [])
        case let .edit(id):
            return .editComment(id: id, content: text, mentions: [])
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
    private func isLastCell(at index: Int) -> Bool {
        guard let commentsCount = reactor?.currentState.comments.count else { return false }
        return commentsCount == (index + 1)
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




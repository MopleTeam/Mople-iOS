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

final class CommentListViewController: DefaultViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = CommentListViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private var hasNextPage: Bool = false
    private var selectedComment: Comment?
    
    // MARK: - Observable
    fileprivate let offset: PublishSubject<CGFloat> = .init()
    fileprivate let selectedPhoto: PublishSubject<Int> = .init()
    fileprivate let userProfileTap: PublishSubject<Comment> = .init()
    fileprivate let writeComment: PublishSubject<String> = .init()
    fileprivate let editCompleted: PublishSubject<Void> = .init()
    fileprivate let editingComment: PublishSubject<String> = .init()
    private let reportComment: PublishSubject<Void> = .init()
    private let deleteComment: PublishSubject<Void> = .init()
    private let fetchComment: PublishSubject<Int> = .init()
    private let moreComment: PublishSubject<Void> = .init()
    
    // MARK: - UI Components
    private let footerIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let defaultFooterView: UIView = {
        let view = UIView(frame: .init(origin: .zero,
                                       size: .init(width: 0, height: 0.1)))
        return view
    }()
    
    private(set) var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.sectionFooterHeight = 0
        table.contentInsetAdjustmentBehavior = .never
        return table
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
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        tableView.register(CommentTableCell.self, forCellReuseIdentifier: CommentTableCell.reuseIdentifier)
        tableView.register(CommentTableHeader.self, forHeaderFooterViewReuseIdentifier: CommentTableHeader.reuseIdentifier)
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
    public func loadComment(with postId: Int?) {
        guard let postId else { return }
        fetchComment.onNext(postId)
    }
    
    public func cancleEdit() {
        selectedComment = nil
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
    
    private func handleWriteComment(_ comment: String) -> Reactor.Action {
        if let selectedComment {
            return .editComment(comment: selectedComment,
                                              content: comment,
                                              mentions: [])
        } else {
            return .createComment(parentId: nil,
                                  content: comment,
                                  mentions: [])
        }
    }

    private func setActionBind(_ reactor: Reactor) {
        fetchComment
            .map { [weak self] in
                let isRefresh = self?.refreshControl.isRefreshing == true
                return Reactor.Action.fetchComment(postId: $0, isRefresh: isRefresh)
            }
            .compactMap({ $0 })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        writeComment
            .compactMap({ [weak self] in self?.handleWriteComment($0) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteComment
            .compactMap({ [weak self] in self?.selectedComment })
            .map { Reactor.Action.deleteComment($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reportComment
            .compactMap({ [weak self] in self?.selectedComment })
            .map { Reactor.Action.reportComment($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        moreComment
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .filter({ [weak self] in self?.hasNextPage ?? false })
            .map { _ in Reactor.Action.moreComment }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        userProfileTap
            .map { Reactor.Action.showWriterImage($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$comments)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: CommentTableCell.reuseIdentifier, cellType: CommentTableCell.self)) { [weak self] index, item, cell in
                let itemCount = reactor.currentState.comments.count - 1
                cell.configure(.init(item, isLast: itemCount == index))
                cell.selectionStyle = .none
                cell.menuTapped = { [weak self] in
                    self?.handleCommentAction(item)
                }
                cell.profileTapped = { [weak self] in
                    self?.userProfileTap.onNext(item)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$pageInfo)
            .subscribe(with: self,
                       onNext: { vc, pageInfo in
                vc.hasNextPage = pageInfo?.hasNext ?? false
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$addedComment)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, _ in
                vc.moveToRecentComment()
                vc.editCompleted.onNext(())
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$editedComment)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, _ in
                vc.selectedComment = nil
                vc.editCompleted.onNext(())
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$reportedComment)
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, _ in
                vc.selectedComment = nil
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
//        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, err in
//                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }
}

extension CommentListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: CommentTableHeader.reuseIdentifier) as! CommentTableHeader
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        offset.onNext(scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        offset.onNext(scrollView.contentOffset.y)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottom(threshold: 200) {
            moreComment.onNext(())
        }
    }
}

// MARK: - Alert
extension CommentListViewController {
    
    // MARK: - 댓글 메뉴버튼 액션
    private func handleCommentAction(_ comment: Comment) {
        selectedComment = comment
        
        if comment.isWriter {
            showEditCommentAlert()
        } else {
            showReportCommentAlert()
        }
    }
    
    // MARK: - 작성자 본인인 경우(편집, 삭제)
    private func showEditCommentAlert() {
        let editComment = editCommentAction()
        let deleteComment = deleteCommentAction()
        sheetManager.showSheet(actions: [editComment,
                                         deleteComment],
                               cancleAction: { [weak self] in
            self?.selectedComment = nil
        })
    }
    
    private func editCommentAction() -> DefaultSheetAction {
        return .init(text: L10n.Comment.edit,
                     image: .editComment,
                     completion: { [weak self] in
            guard let selectedComment = self?.selectedComment,
                  let comment = selectedComment.comment else { return }
            self?.editingComment.onNext(comment)
        })
    }
    
    private func deleteCommentAction() -> DefaultSheetAction {
        return .init(text: L10n.Comment.delete,
                     image: .delete,
                     completion: { [weak self] in
            self?.deleteComment.onNext(())
        })
    }
    
    // MARK: - 작성자가 아닌 경우(신고)
    private func showReportCommentAlert() {
        let reportComment = reportCommentAction()
        sheetManager.showSheet(actions: [reportComment],
                               cancleAction: { [weak self] in
            self?.selectedComment = nil
        })
    }
    
    private func reportCommentAction() -> DefaultSheetAction {
        return .init(text: L10n.Report.comment,
                     image: .report,
                     completion: { [weak self] in
            self?.reportComment.onNext(())
        })
    }
}

// MARK: - Helper
extension CommentListViewController {
    private func moveToRecentComment() {
        let lastSection = tableView.numberOfSections - 1
        tableView.scrollToRow(at: .init(row: 0, section: lastSection),
                              at: .middle,
                              animated: true)
    }
    
    private func handleLoadingType(isLoad: Bool, mode: LoadMode) {
        switch mode {
        case .edit:
            self.rx.isLoading.onNext(isLoad)
        case .more:
            tableView.tableFooterView = isLoad ? footerIndicator : defaultFooterView
            stopRefreshControl(isLoad: isLoad)
        case .refresh:
            stopRefreshControl(isLoad: isLoad)
        }
    }
    
    /// - Footer 로딩 완료 후 남아있는 RefreshControl 상태를 정리
    /// - RefreshControl은 사용자 제스처로 인해 UI상 활성화 가능
    /// - Footer 로딩 중에는 실제 refresh 로직이 실행되지 않으므로 수동 종료
    private func stopRefreshControl(isLoad: Bool) {
        guard refreshControl.isRefreshing, !isLoad else { return }
        refreshControl.endRefreshing()
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
    
    var uploadedComment: Observable<Void> {
        return base.editCompleted
    }
    
    var offset: Observable<CGFloat> {
        return base.offset
    }
    
    var refresh: Observable<Void> {
        return base.refreshControl.rx.controlEvent(.valueChanged)
            .filter { base.refreshControl.isRefreshing }
    }
}





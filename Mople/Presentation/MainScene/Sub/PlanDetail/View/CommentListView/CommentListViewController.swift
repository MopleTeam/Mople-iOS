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

final class CommentListViewController: BaseViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = CommentListViewReactor
    private var commentListReactor: CommentListViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let offset: PublishSubject<CGFloat> = .init()
    private let selectedPhoto: PublishSubject<Int> = .init()
    private let selectedComment: PublishSubject<Comment?> = .init()
    private let editComment: PublishSubject<Void> = .init()
    private let deleteComment: PublishSubject<Void> = .init()
    private let reportComment: PublishSubject<Void> = .init()
    
    // MARK: - DataSource
    private var dataSource: RxTableViewSectionedReloadDataSource<CommentTableSectionModel>?
    
    // MARK: - UI Components
    private(set) var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.tableFooterView = .init(frame: .init(origin: .zero,
                                                   size: .init(width: 0, height: 0.1)))
        table.sectionFooterHeight = 0
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    // MARK: - LifeCycle
    init(reactor: CommentListViewReactor) {
        super.init()
        self.commentListReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setTableView()
        setLayout()
    }
    
    private func setTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        tableView.register(CommentTableCell.self, forCellReuseIdentifier: CommentTableCell.reuseIdentifier)
        tableView.register(PhotoViewTableCell.self, forCellReuseIdentifier: PhotoViewTableCell.reuseIdentifier)
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
    }
}

// MARK: - Reactor Setup
extension CommentListViewController {
    private func setReactor() {
        reactor = commentListReactor
    }
    
    func bind(reactor: CommentListViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        offset
            .map { Reactor.Action.childEvent(.offsetChanged($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        selectedPhoto
            .map { Reactor.Action.childEvent(.selectedPhoto($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        selectedComment
            .map { Reactor.Action.selctedComment(comment: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        editComment
            .map { Reactor.Action.childEvent(.editComment) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteComment
            .map { Reactor.Action.deleteComment }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reportComment
            .map { Reactor.Action.reportComment }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        setupDataSource()
        
        reactor.pulse(\.$sectionModels)
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$createdCompletion)
            .observe(on: MainScheduler.asyncInstance)
            .delay(.milliseconds(20), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, _ in
                vc.moveToLastComment()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - DataSource
extension CommentListViewController {
    private func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<CommentTableSectionModel>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                guard let self else { return UITableViewCell() }
                switch item {
                case let .comment(comment):
                    let lastIndex = dataSource.sectionModels[indexPath.section].items.count - 1
                    return makeCommentTableCell(comment: comment,
                                                lastIndex: lastIndex,
                                                row: indexPath.row)
                case let .photo(images):
                    return makePhotoContainerCell(images)
                }
            }
        )
    }
    
    private func makeCommentTableCell(comment: Comment,
                                      lastIndex: Int,
                                      row: Int) -> CommentTableCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableCell.reuseIdentifier) as! CommentTableCell
        cell.configure(.init(comment,
                             isLast: lastIndex == row))
        cell.selectionStyle = .none
        cell.menuTapped = { [weak self] in
            self?.selectedComment.onNext(comment)
            self?.handleCommentAction(comment)
        }
        return cell
    }
    
    private func makePhotoContainerCell(_ images: [UIImage]) -> PhotoViewTableCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoViewTableCell.reuseIdentifier) as! PhotoViewTableCell
        cell.configure(images)
        cell.photoTapped = { [weak self] index in
            self?.selectedPhoto.onNext(index)
        }
        return cell
    }
}

extension CommentListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let dataSource else { return UITableView.automaticDimension }
        let type = dataSource.sectionModels[indexPath.section].type
        return type.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: CommentTableHeader.reuseIdentifier) as! CommentTableHeader
        
        guard let dataSource else { return nil}
        let model = dataSource.sectionModels[section]
        header.setTitle(model.type.title)
        
        if case .photo(let images) = model.items.first {
            header.setCount(images.count)
        } else {
            header.setCount(model.items.count)
        }

        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 68
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        offset.onNext(scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        offset.onNext(scrollView.contentOffset.y)
    }
}

// MARK: - Alert
extension CommentListViewController {
    
    // MARK: - 댓글 메뉴버튼 액션
    private func handleCommentAction(_ comment: Comment) {
        if comment.isWriter {
            showEditCommentAlert()
        } else {
            showReportCommentAlert()
        }
    }
    
    // MARK: - 작성자 본인인 경우(편집, 삭제)
    private func showEditCommentAlert() {
        alertManager.showActionSheet(actions: [editCommentAction(),
                                               deleteCommentAction()],
                                     cancleCompletion: { [weak self] _ in
            self?.selectedComment.onNext(nil)
        })
    }
    
    private func editCommentAction() -> UIAlertAction {
        return alertManager.makeAction(title: "댓글 수정",
                                       completion: { [weak self] in
            self?.editComment.onNext(())
        })
    }
    
    private func deleteCommentAction() -> UIAlertAction {
        return alertManager.makeAction(title: "댓글 삭제",
                                       style: .destructive,
                                       completion: { [weak self] in
            self?.deleteComment.onNext(())
        })
    }
    
    // MARK: - 작성자가 아닌 경우(신고)
    private func showReportCommentAlert() {
        alertManager.showActionSheet(actions: [reportCommentAction()],
                                     cancleCompletion: { [weak self] _ in
            self?.selectedComment.onNext(nil)
        })
    }
    
    private func reportCommentAction() -> UIAlertAction {
        return alertManager.makeAction(title: "댓글 신고",
                                       style: .destructive,
                                       completion: { [weak self] in
            self?.reportComment.onNext(())
        })
    }
}

// MARK: - Helper
extension CommentListViewController {
    private func moveToLastComment() {
        tableView.scrollToBottom(animated: false)
    }
}






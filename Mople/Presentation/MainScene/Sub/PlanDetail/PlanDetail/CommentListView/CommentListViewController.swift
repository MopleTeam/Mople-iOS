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
    
    typealias Reactor = CommentListViewReactor
    
    var disposeBag = DisposeBag()

    // MARK: - Alert
    private let alertManager = AlertManager.shared

    private var dataSource: RxTableViewSectionedReloadDataSource<CommentTableSectionModel>?
    
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
    
    init(reactor: CommentListViewReactor) {
        super.init()
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(#function, #line, "sectionHeaderTopPadding : \(tableView.sectionHeaderTopPadding)" )
    }

    public func setHeaderView(_ headerView: UIView) {
        self.tableView.tableHeaderView = headerView
    }
    
    private func initalSetup() {
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
    
    func bind(reactor: CommentListViewReactor) {
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

extension CommentListViewController {
    private func moveToLastComment() {
        tableView.scrollToBottom(animated: false)
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
            self?.reactor?.action.onNext(.selctedComment(comment: comment))
            self?.handleCommentAction(comment)
        }
        return cell
    }
    
    private func makePhotoContainerCell(_ images: [UIImage]) -> PhotoViewTableCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoViewTableCell.reuseIdentifier) as! PhotoViewTableCell
        cell.configure(images)
        cell.photoTapped = { [weak self] index in
            self?.reactor?.action.onNext(.childEvent(.selectedPhoto(index)))
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
        reactor?.action.onNext(.childEvent(.offsetChanged(scrollView.contentOffset.y)))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        reactor?.action.onNext(.childEvent(.offsetChanged(scrollView.contentOffset.y)))
    }
}

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
        alertManager.showActionSheet(actions: [editComment(), deleteComment()],
                                     cancleCompletion: { [weak self] _ in
            self?.reactor?.action.onNext(.selctedComment(comment: nil))
        })
    }
    
    private func editComment() -> UIAlertAction {
        return alertManager.makeAction(title: "댓글 수정",
                                       completion: { [weak self] in
            self?.reactor?.action.onNext(.childEvent(.editComment))
        })
    }
    
    private func deleteComment() -> UIAlertAction {
        return alertManager.makeAction(title: "댓글 삭제",
                                       style: .destructive,
                                       completion: { [weak self] in
            self?.reactor?.action.onNext(.deleteComment)
        })
    }
    
    // MARK: - 작성자가 아닌 경우(신고)
    private func showReportCommentAlert() {
        alertManager.showActionSheet(actions: [reportComment()],
                                     cancleCompletion: { [weak self] _ in
            print(#function, #line, "Path : # 댓글 편집 취소 ")
            self?.reactor?.action.onNext(.selctedComment(comment: nil))
        })
    }
    
    private func reportComment() -> UIAlertAction {
        return alertManager.makeAction(title: "댓글 신고",
                                       style: .destructive,
                                       completion: { [weak self] in
            self?.reactor?.action.onNext(.childEvent(.reportComment))
        })
    }
}








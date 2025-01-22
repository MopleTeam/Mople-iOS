//
//  CommentListView.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import UIKit
import SnapKit
import ReactorKit

final class CommentListViewController: BaseViewController, View {
    
    typealias Reactor = CommentListViewReactor
    
    var disposeBag = DisposeBag()
    
    private var commentCount: Int = 0
    
    private let countView: CountView = {
        let view = CountView(title: "댓글")
        view.frame.size.height = 58
        view.setSpacing(8)
        return view
    }()
    
    private let tableView: AutoSizingTableView = {
        let table = AutoSizingTableView()
        table.isScrollEnabled = false
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
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
        setHeaderView()
    }
    
    private func initalSetup() {
        setTableView()
        setLayout()
    }
    
    private func setTableView() {
        tableView.register(CommentTableCell.self, forCellReuseIdentifier: CommentTableCell.reuseIdentifier)
    }
    
    private func setLayout() {
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setHeaderView() {
        guard tableView.tableHeaderView == nil else { return }
        tableView.tableHeaderView = countView
    }
    
    func bind(reactor: CommentListViewReactor) {
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        let loadCommentList = Observable.combineLatest(viewDidLayout, reactor.pulse(\.$commentList))
            .map({ $0.1 })
            .do { [weak self] in
                self?.commentCount = $0.count
            }
            .share()
        
        loadCommentList
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: CommentTableCell.reuseIdentifier,
                                           cellType: CommentTableCell.self)) { [weak self] index, item, cell in
                guard let self else { return }
                let lastCount = self.commentCount - 1
                cell.hideLine(isLast: lastCount == index)
                cell.configure(.init(comment: item))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        loadCommentList
            .map({ $0.count })
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self, onNext: { vc, count in
                vc.countView.countText = "\(count)개"
            })
            .disposed(by: disposeBag)
    }
}



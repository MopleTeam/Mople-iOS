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
    
    typealias Reactor = PlanDetailViewReactor
    
    var disposeBag = DisposeBag()
    
    private lazy var countView: CountView = {
        let view = CountView(title: "댓글",
                             frame: .init(width: tableView.bounds.width,
                                          height: 58))
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
    
    init(reactor: PlanDetailViewReactor) {
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
        tableView.tableHeaderView = countView
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
    
    func bind(reactor: PlanDetailViewReactor) {
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        let array = Array(1...10)
            .map { index in
                Meet.mock(id: index, creatorId: 1)
            }
        
        Observable.just(array)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: CommentTableCell.reuseIdentifier, cellType: CommentTableCell.self)) { index, item, cell in
                cell.hideLine(isLast: array.count-1 == index)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        Observable.just(array)
            .map({ $0.count })
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self, onNext: { vc, count in
                vc.countView.countText = "\(count)개"
            })
            .disposed(by: disposeBag)
    }
    
}



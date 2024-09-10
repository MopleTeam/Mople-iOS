//
//  GroupListTableViewController.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

final class GroupListTableViewController: UIViewController, View {
    
    typealias Reactor = GroupListViewReactor
    var disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.clipsToBounds = false
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    init(reactor: GroupListViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    
    private func setupUI() {
        self.view.backgroundColor = .clear
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview().inset(28)
        }
    }
    
    private func setupTableView() {
        self.tableView.register(GroupListCell.self, forCellReuseIdentifier: GroupListCell.reuseIdentifier)
    }
    
    func bind(reactor: GroupListViewReactor) {
        reactor.pulse(\.$groupList)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: GroupListCell.reuseIdentifier, cellType: GroupListCell.self)) { index, item, cell in
                
                cell.selectionStyle = .none
                
            }
            .disposed(by: disposeBag)
    }
}

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
    
    private let headerView = UIView()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.clipsToBounds = false
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
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
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

extension GroupListTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
}

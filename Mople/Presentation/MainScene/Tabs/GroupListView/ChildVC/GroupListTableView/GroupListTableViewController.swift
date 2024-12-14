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
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.contentInset = .init(top: 28, left: 0, bottom: 10, right: 0)
        table.clipsToBounds = false
        return table
    }()
    
    init(reactor: GroupListViewReactor) {
        print(#function, #line, "LifeCycle Test GroupList TableView Created" )
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test GroupList TableView Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setAction()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.register(GroupListTableCell.self, forCellReuseIdentifier: GroupListTableCell.reuseIdentifier)
    }
    
    private func setAction() {
        tableView.rx.itemSelected
            .subscribe(with: self, onNext: { vc, _ in

            })
            .disposed(by: disposeBag)
    }
    
    
    func bind(reactor: GroupListViewReactor) {
        reactor.pulse(\.$groupList)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: GroupListTableCell.reuseIdentifier, cellType: GroupListTableCell.self)) { index, item, cell in
                cell.configure(with: ThumbnailViewModel(group: item.commonGroup,
                                                        memberCount: item.memberCount,
                                                        lastScheduleDate: item.lastScheduleDate))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
    }
}

extension GroupListTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }
}

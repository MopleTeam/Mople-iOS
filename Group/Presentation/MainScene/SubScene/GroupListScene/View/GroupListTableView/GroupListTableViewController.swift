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

final class GroupListTableViewController: UIViewController, View, UIScrollViewDelegate {
    
    typealias Reactor = GroupListViewReactor
    var disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.contentInset = .init(top: 28, left: 0, bottom: 50, right: 0)
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
        setAction()
    }
    
    
    private func setupUI() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        self.tableView.register(GroupListCell.self, forCellReuseIdentifier: GroupListCell.reuseIdentifier)
    }
    
    private func setAction() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(with: self, onNext: { vc, _ in
                print("셀 선택 됨")
            })
            .disposed(by: disposeBag)
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


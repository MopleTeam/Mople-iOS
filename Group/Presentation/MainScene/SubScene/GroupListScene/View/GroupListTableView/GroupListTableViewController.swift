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
        table.tableHeaderView = UIView.init(frame: .init(x: 0, y: 0, width: table.frame.width, height: 10))
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
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.register(GroupListCell.self, forCellReuseIdentifier: GroupListCell.reuseIdentifier)
    }
    
    private func setAction() {
        tableView.rx.itemSelected
            .subscribe(with: self, onNext: { vc, _ in
                let testVC = TestVC()
                testVC.hidesBottomBarWhenPushed = true
                vc.navigationController?.pushViewController(testVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    func bind(reactor: GroupListViewReactor) {
        reactor.pulse(\.$groupList)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: GroupListCell.reuseIdentifier, cellType: GroupListCell.self)) { index, item, cell in
                cell.configure(with: ThumbnailViewModel(group: item))
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

class TestVC: UIViewController {
    
    override func viewDidLoad() {
        
        view.backgroundColor = .systemMint
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        print(#function, #line)
//        super.viewWillDisappear(animated)
//        
//        self.tabBarController?.tabBar.isHidden = false
//    }
}

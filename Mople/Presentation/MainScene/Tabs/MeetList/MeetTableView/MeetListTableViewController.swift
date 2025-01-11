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

final class MeetListTableViewController: BaseViewController, View, UIScrollViewDelegate {
    
    typealias Reactor = MeetListViewReactor
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
    
    private let emptyView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setTitle(text: TextStyle.GroupList.emptyTitle)
        view.setImage(image: .emptyGroup)
        return view
    }()
    
    init(reactor: MeetListViewReactor) {
        super.init()
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
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(MeetListTableCell.self, forCellReuseIdentifier: MeetListTableCell.reuseIdentifier)
    }
    
    func bind(reactor: MeetListViewReactor) {
      
    }
}

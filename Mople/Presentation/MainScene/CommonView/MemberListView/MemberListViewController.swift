//
//  MemberListViewController.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

final class MemberListViewController: TitleNaviViewController, View, UIScrollViewDelegate {
    
    typealias Reactor = MemberListViewReactor
    
    var disposeBag = DisposeBag()
    
    private let countView: CountView = {
        let view = CountView(title: "참여자 목록")
        view.frame.size.height = 64
        view.setBottomInset(16)
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: ColorStyle.Gray._04)
        return view
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.clipsToBounds = true
        return table
    }()
    
    init(title: String,
         reactor: MemberListViewReactor) {
        super.init(title: title)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
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
        setNaviItem()
        setupTableView()
        setupUI()
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(MemberListTableCell.self,
                                forCellReuseIdentifier: MemberListTableCell.reuseIdentifier)
    }
    
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.Default.white
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func bind(reactor: MemberListViewReactor) {
        naviBar.leftItemEvent
            .map { Reactor.Action.endFlow }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$members)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: MemberListTableCell.reuseIdentifier,
                                           cellType: MemberListTableCell.self)) { index, item, cell in
                cell.configure(with: .init(memberInfo: item))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$members)
            .asDriver(onErrorJustReturn: [])
            .map({ $0.count })
            .drive(with: self, onNext: { vc, count in
                vc.countView.countText = "\(count)명"
            })
            .disposed(by: disposeBag)
    }
}

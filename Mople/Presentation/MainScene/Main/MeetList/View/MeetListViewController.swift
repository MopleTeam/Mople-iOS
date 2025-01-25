//
//  GroupViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class MeetListViewController: TitleNaviViewController, View, UIScrollViewDelegate {
    
    typealias Reactor = MeetListViewReactor
    
    var disposeBag = DisposeBag()
    
    private let borderView: UIView = {
        let view = UIView()
        view.layer.makeLine(width: 1)
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = ColorStyle.BG.primary
        table.showsVerticalScrollIndicator = false
        table.tableHeaderView = .init(frame: .init(origin: .zero,
                                                   size: .init(width: 0,
                                                               height: 28)))
        table.clipsToBounds = true
        return table
    }()
    
    private let emptyView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.backgroundColor = ColorStyle.BG.primary
        view.setTitle(text: TextStyle.GroupList.emptyTitle)
        view.setImage(image: .emptyGroup)
        return view
    }()
    
    init(title: String?,
         reactor: MeetListViewReactor) {
        super.init(title: title)
        self.reactor = reactor
        setNotification(reactor: reactor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }
    
    private func initalSetup() {
        setLayout()
        setupTableView()
    }

    private func setLayout() {
        self.view.addSubview(tableView)
        self.view.addSubview(borderView)
        self.view.addSubview(emptyView)
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(MeetListTableCell.self, forCellReuseIdentifier: MeetListTableCell.reuseIdentifier)
    }
    
    private func setNotification(reactor: Reactor) {
        EventService.shared.addMeetObservable()
            .map { Reactor.Action.updateMeet($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: MeetListViewReactor) {
        tableView.rx.itemSelected
            .map({ Reactor.Action.selectMeet(index: $0.row) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        let responseMeets = Observable.combineLatest(viewDidLayout, reactor.pulse(\.$meetList))
            .map { $0.1 }
            .share()
        
        responseMeets
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, groupList in
                vc.emptyView.isHidden = !groupList.isEmpty
                vc.tableView.isHidden = groupList.isEmpty
            })
            .disposed(by: disposeBag)

        responseMeets
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: MeetListTableCell.reuseIdentifier, cellType: MeetListTableCell.self)) { index, item, cell in
                cell.configure(with: .init(meet: item))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
    }
}







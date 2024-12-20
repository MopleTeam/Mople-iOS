//
//  GroupSelectViewController.swift
//  Mople
//
//  Created by CatSlave on 12/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

final class GroupSelectViewController: UIViewController, View {
    
    typealias Reactor = PlanCreateViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var sheetView: CompactSheet = {
        let view = CompactSheet(contentView: tableView)
        view.setTitle("테스트")
        return view
    }()
    
    init(reactor: PlanCreateViewReactor) {
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
        setPresentationStyle()
        setAction()
    }
    
    // MARK: - ModalStyle
    private func setPresentationStyle() {
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [ .medium() ]
    }
    
    private func setupUI() {
        view.addSubview(sheetView)
        
        sheetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(GroupSelectTableCell.self, forCellReuseIdentifier: GroupSelectTableCell.reuseIdentifier)
    }
    
    // MARK: - Binding
    func bind(reactor: PlanCreateViewReactor) {
        tableView.rx.itemSelected
            .asDriver()
            .map { Reactor.Action.setSelectedMeet(index: $0.row) }
            .drive(with: self, onNext: { vc, action  in
                reactor.action.onNext(action)
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(self.rx.viewWillAppear, reactor.pulse(\.$meets))
            .map({ $0.1 })
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: GroupSelectTableCell.reuseIdentifier, cellType: GroupSelectTableCell.self)) { index, item, cell in
      
                cell.configure(with: .init(meet: item))
            }
            .disposed(by: disposeBag)
    }
    
    private func setAction() {
        sheetView.closeButtonTap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension GroupSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(#function, #line, "indexPath : \(indexPath)" )
        return 60
    }
}


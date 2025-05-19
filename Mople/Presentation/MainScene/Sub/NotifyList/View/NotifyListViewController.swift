//
//  NotifyListViewController.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

final class NotifyListViewController: TitleNaviViewController, View, UITableViewDelegate {
    
    // MARK: - Reactor
    typealias Reactor = NotifyListViewReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Transition
    var dismissTransition: AppTransition = .init(type: .dismiss)
    
    // MARK: - UI Components
    private let countView: CountView = {
        let view = CountView(title: L10n.Notifylist.new)
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: .gray04)
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    private let emptyNotifyView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setTitle(text: L10n.Notifylist.empty)
        view.setImage(image: .emptyNotify)
        return view
    }()
    
    // MARK: - Refresh Control
    private let refreshControl = UIRefreshControl()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         reactor: NotifyListViewReactor) {
        super.init(screenName: screenName,
                   title: title)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavi()
        setLayout()
        setupTableView()
    }
    
    private func setLayout() {
        self.view.addSubview(countView)
        self.view.addSubview(emptyNotifyView)
        self.view.addSubview(tableView)
        
        self.countView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom).offset(28)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.emptyNotifyView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(countView.snp.bottom).offset(16)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setupNavi() {
        self.setBarItem(type: .left)
    }
    
    private func setupTableView() {
        tableView.refreshControl = refreshControl
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(NotifyTableCell.self, forCellReuseIdentifier: NotifyTableCell.reuseIdentifier)
    }
    
    private func setCount(_ count: Int) {
        countView.countText = L10n.itemCount(count)
    }
}

// MARK: - Reactor Setup
extension NotifyListViewController {

    func bind(reactor: NotifyListViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }

    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
    }
    
    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }

    private func setActionBind(_ reactor: Reactor) {
        tableView.rx.itemSelected
            .map { Reactor.Action.flow(.selectNotify(index: $0.row)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.naviBar.leftItemEvent
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$notifyList)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(
                cellIdentifier: NotifyTableCell.reuseIdentifier,
                cellType: NotifyTableCell.self)
            ) { index, item, cell in
                cell.configure(viewModel: .init(notify: item))
                cell.setReadStatus(isNew: item.isNew)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$notifyList)
            .asDriver(onErrorJustReturn: [])
            .map { $0
                .filter { $0.isNew }
                .count
            }
            .drive(with: self, onNext: { vc, newCount in
                vc.setCount(newCount)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$notifyList)
            .asDriver(onErrorJustReturn: [])
            .map { !$0.isEmpty }
            .drive(with: self, onNext: { vc, hasNotify in
                vc.tableView.isHidden = !hasNotify
                vc.emptyNotifyView.isHidden = hasNotify
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isRefreshed)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: ())
            .map({ false })
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, _ in
                vc.alertManager.showDefatulErrorMessage()
            })
            .disposed(by: disposeBag)
    }
}

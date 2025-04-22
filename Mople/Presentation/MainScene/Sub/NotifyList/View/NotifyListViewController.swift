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
    private var notifyListReactor: NotifyListViewReactor?
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Transition
    var dismissTransition: AppTransition = .init(type: .dismiss)
    
    // MARK: - UI Components
    private let countView: CountView = {
        let view = CountView(title: "새로운 알림")
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: ColorStyle.Gray._04)
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    private let emptyPlanView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setTitle(text: TextStyle.Calendar.emptyTitle)
        view.setImage(image: .emptyPlan)
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    // MARK: - LifeCycle
    init(title: String?,
         reactor: NotifyListViewReactor) {
        super.init(title: title)
        self.notifyListReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavi()
        setLayout()
        setupTableView()
    }
    
    private func setLayout() {
        self.view.addSubview(countView)
        self.view.addSubview(emptyPlanView)
        self.view.addSubview(tableView)
        
        self.countView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom).offset(28)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.emptyPlanView.snp.makeConstraints { make in
            make.top.equalTo(countView.snp.bottom).offset(16)
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
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(NotifyTableCell.self, forCellReuseIdentifier: NotifyTableCell.reuseIdentifier)
    }
    
    private func setCount(_ count: Int) {
        countView.countText = "\(count)개"
    }
}

// MARK: - Reactor Setup
extension NotifyListViewController {
    private func setReactor() {
        reactor = notifyListReactor
    }
    
    func bind(reactor: NotifyListViewReactor) {
        inputBind(reactor)
        outpubBind(reactor)
    }

    private func inputBind(_ reactor: Reactor) {
        tableView.rx.itemSelected
            .map { Reactor.Action.selectNotify(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.naviBar.leftItemEvent
            .map { Reactor.Action.endFlow }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func outpubBind(_ reactor: Reactor) {
        reactor.pulse(\.$notifyList)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(
                cellIdentifier: NotifyTableCell.reuseIdentifier,
                cellType: NotifyTableCell.self)
            ) { index, item, cell in
                cell.configure(viewModel: .init(notify: item))
                cell.setReadStatus(isNew: item.isNew)
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
        
        reactor.pulse(\.$resetedCount)
            .compactMap({ $0 })
            .do(onNext: { _ in
                print(#function, #line, "Path : # 값이 들어옴 ")
            })
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { _ in
                UIApplication.shared.applicationIconBadgeNumber = 0
            })
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

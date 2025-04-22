//
//  FuturePlanListViewController.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class MeetPlanListViewController: BaseViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = MeetPlanListViewReactor
    private var meetPlanReactor: MeetPlanListViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let reset: PublishSubject<Void> = .init()
            
    // MARK: - Variables
    private var hasAppeared: Bool = false
    
    // MARK: - UI Components
    private let countView: CountView = {
        let view = CountView(title: "예정된 약속")
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: ColorStyle.Gray._04)
        view.setBottomInset(16)
        view.frame.size.height = 64
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
    init(reactor: Reactor) {
        super.init()
        self.meetPlanReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setHeaderView()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setupTableView()
    }
    
    private func setLayout() {
        self.view.addSubview(emptyPlanView)
        self.view.addSubview(tableView)
        
        emptyPlanView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(MeetPlanTableCell.self, forCellReuseIdentifier: MeetPlanTableCell.reuseIdentifier)
    }
    
    private func setHeaderView() {
        guard hasAppeared == false else { return }
        hasAppeared = true
        tableView.tableHeaderView = countView
    }
    
    private func setPlanList(with planList: [Plan]) {
        emptyPlanView.isHidden = !planList.isEmpty
        tableView.isHidden = planList.isEmpty
        setPlanCountLabel(planList: planList)
    }
    
    private func setPlanCountLabel(planList: [Plan]) {
        guard planList.isEmpty == false else { return }
        countView.countText = "\(planList.count)개"
    }
    
    private func reloadCell(at index: Int) {
        tableView.reloadRows(at: [.init(row: index, section: 0)], with: .none)
    }
}

// MARK: - Reactor Setup
extension MeetPlanListViewController {
    private func setReactor() {
        reactor = meetPlanReactor
    }
    
    func bind(reactor: MeetPlanListViewReactor) {
        setInput(reactor: reactor)
        setOutput(reactor: reactor)
        setNotification(reactor: reactor)
    }
    
    private func setInput(reactor: Reactor) {
        tableView.rx.itemSelected
            .map({ Reactor.Action.selectedPlan(index: $0.row) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reset
            .map { Reactor.Action.requestPlanList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setOutput(reactor: Reactor) {
        reactor.pulse(\.$plans)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, planList in
                vc.setPlanList(with: planList)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$plans)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(
                cellIdentifier: MeetPlanTableCell.reuseIdentifier,
                cellType: MeetPlanTableCell.self)
            ) { [weak self] index, item, cell in
                cell.configure(viewModel: .init(plan: item))
                cell.selectionStyle = .none
                cell.completeTapped = { [weak self] in
                    guard let planId = item.id else { return }
                    let action = Reactor.Action.updateParticipants(id: planId,
                                                                   isJoining: item.isParticipating)
                    self?.reactor?.action.onNext(action)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$closingPlanIndex)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, index in
                vc.reloadCell(at: index)
            })
            .disposed(by: disposeBag)
    }

    private func setNotification(reactor: Reactor) {
        NotificationManager.shared.addPlanObservable()
            .map { Reactor.Action.updatePlan($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

extension MeetPlanListViewController: UITableViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView.isRefresh() else { return }
        reset.onNext(())
    }
}



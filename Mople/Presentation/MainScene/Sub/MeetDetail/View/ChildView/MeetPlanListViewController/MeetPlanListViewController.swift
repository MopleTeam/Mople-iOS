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
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let participation: PublishSubject<(id: Int,
                                               isJoining: Bool)> = .init()
    private let refresh: PublishSubject<Void> = .init()
            
    // MARK: - Variables
    private var hasAppeared: Bool = false
    private var isVisibleView: Bool = false
    
    // MARK: - UI Components
    private let countView: CountView = {
        let view = CountView(title: L10n.Meetdetail.planlist)
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: .gray04)
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
        view.setTitle(text: L10n.Meetdetail.emptyPost)
        view.setImage(image: .emptyPlan)
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    // MARK: - LifeCycle
    init(reactor: Reactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisibleView = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisibleView = false
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
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
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
        setPlanCountLabel(count: planList.count)
    }
    
    private func setPlanCountLabel(count: Int) {
        guard count > 0 else { return }
        countView.countText = "\(count)개"
    }
    
    private func reloadCell(at index: Int) {
        tableView.reloadRows(at: [.init(row: index, section: 0)], with: .none)
    }
}

// MARK: - Reactor Setup
extension MeetPlanListViewController {

    func bind(reactor: MeetPlanListViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
        setNotificationBind(reactor)
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
            .map({ Reactor.Action.selectedPlan(index: $0.row) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        participation
            .map { Reactor.Action.requsetParticipation(id: $0.id,
                                                       isJoining: $0.isJoining) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refresh
            .map({ Reactor.Action.refresh })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setNotificationBind(_ reactor: Reactor) {
        NotificationManager.shared.addPlanObservable()
            .map { Reactor.Action.updatePlan($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addParticipatingObservable()
            .filter { [weak self] _ in
                return self?.isVisibleView == false
            }
            .compactMap { [weak self] payload -> Reactor.Action? in
                guard let self else { return nil }
                return resolveParticipation(with: payload)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func resolveParticipation(with payload: PlanPayload) -> Reactor.Action? {
        switch payload {
        case let .created(plan):
            guard let id = plan.id else { return nil }
            return .switchParticipation(id: id)
        case let .deleted(id):
            return .switchParticipation(id: id)
        default:
            return nil
        }
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
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
                    self?.handleParticipationPlan(id: planId,
                                                  isJoining: item.isParticipation)
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
    
    /// 참여, 불참 요청
    private func handleParticipationPlan(id: Int, isJoining: Bool) {
        participation.onNext((id, isJoining))
    }
}

extension MeetPlanListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.isRefresh() else { return }
        refresh.onNext(())
    }
}

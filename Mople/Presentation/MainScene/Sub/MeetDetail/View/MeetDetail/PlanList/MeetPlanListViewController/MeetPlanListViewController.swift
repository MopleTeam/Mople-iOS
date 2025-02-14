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
    
    typealias Reactor = MeetPlanListViewReactor
    
    var disposeBag = DisposeBag()
        
    private var parentReactor: MeetDetailViewReactor?
    
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
    
    init(reactor: Reactor,
         parentReactor: MeetDetailViewReactor?) {
        super.init()
        self.reactor = reactor
        self.parentReactor = parentReactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView = countView // 테이블뷰의 크기가 정해진 다음 할당해야 경고가 발생하지 않음
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
    }
    
    private func setOutput(reactor: Reactor) {
        reactor.pulse(\.$plans)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, planList in
                let isEmpty = planList.isEmpty
                vc.emptyPlanView.isHidden = !isEmpty
                vc.tableView.isHidden = isEmpty
                vc.setPlanCountLabel(planList: planList)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$plans)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(
                cellIdentifier: MeetPlanTableCell.reuseIdentifier,
                cellType: MeetPlanTableCell.self)
            ) { index, item, cell in

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
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isLoading in
                vc.parentReactor?.action.onNext(.planLoading(isLoading))
            })
            .disposed(by: disposeBag)
    }
    
    private func setNotification(reactor: Reactor) {
        EventService.shared.addPlanObservable()
            .map { Reactor.Action.updatePlan($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setPlanCountLabel(planList: [Plan]) {
        guard planList.isEmpty == false else { return }
        countView.countText = "\(planList.count)개"
    }
}

extension MeetPlanListViewController: UITableViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView.contentOffset.y < -60 else { return }
        reactor?.action.onNext(.requestPlanList)
    }
}



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

final class FuturePlanListViewController: UIViewController, View {
    
    typealias Reactor = FuturePlanListViewReactor
    
    var disposeBag = DisposeBag()
    
    private var userID = UserInfoStorage.shared.userInfo?.id
    private var parentReactor: MeetDetailViewReactor?
    private var planCount: Int = 0
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.sectionFooterHeight = 8
        table.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: table.bounds.width, height: 28))
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
    
    init(reactor: Reactor?,
         parentReactor: MeetDetailViewReactor) {
        print(#function, #line, "LifeCycle Test FuturePlanListViewController Created" )

        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.parentReactor = parentReactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test FuturePlanListViewController Deinit" )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        self.tableView.register(FuturePlanTableCell.self, forCellReuseIdentifier: FuturePlanTableCell.reuseIdentifier)
        self.tableView.register(MeetPlanTableHeaderView.self, forHeaderFooterViewReuseIdentifier: MeetPlanTableHeaderView.reuseIdentifier)
    }
    
    func bind(reactor: FuturePlanListViewReactor) {
        reactor.pulse(\.$plans)
            .asDriver(onErrorJustReturn: [])
            .map({ $0.isEmpty })
            .drive(with: self, onNext: { vc, isEmpty in
                vc.emptyPlanView.isHidden = !isEmpty
                vc.tableView.isHidden = isEmpty
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$plans)
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] plans in
                self?.planCount = plans.count
            })
            .drive(self.tableView.rx.items(cellIdentifier: FuturePlanTableCell.reuseIdentifier, cellType: FuturePlanTableCell.self)) { [weak self] index, item, cell in
                
                guard let self else { return }

                cell.configure(viewModel: .init(plan: item), userID: self.userID)
                cell.selectionStyle = .none
                
                cell.rx.completed
                    .map { Reactor.Action.updateParticipants(id: $0,
                                                             isJoining: item.isParticipating) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isLoading in
                vc.parentReactor?.action.onNext(.futurePlanLoading(isLoading))
            })
            .disposed(by: disposeBag)
    }
}

extension FuturePlanListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MeetPlanTableHeaderView.reuseIdentifier) as! MeetPlanTableHeaderView
        header.setLabel(title: "예정된 약속", count: planCount)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView.contentOffset.y < -60 else { return }
        reactor?.action.onNext(.requestPlanList)
    }
}



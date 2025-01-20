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
    
    private var userID = UserInfoStorage.shared.userInfo?.id
    private var parentReactor: MeetDetailViewReactor?
    
    private lazy var countView: CountView = {
        let view = CountView(title: "예정된 약속",
                             frame: .init(width: tableView.bounds.width,
                                          height: 64))
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: ColorStyle.Gray._04)
        view.setSpacing(16)
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
        tableView.tableHeaderView = countView
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
        tableView.rx.itemSelected
            .map({ Reactor.Action.selectedPlan(index: $0.row) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        let responsePlans = Observable.combineLatest(viewDidLayout, reactor.pulse(\.$plans))
            .map { $0.1 }
            .share()
        
        responsePlans
            .asDriver(onErrorJustReturn: [])
            .map({ $0.isEmpty })
            .drive(with: self, onNext: { vc, isEmpty in
                vc.emptyPlanView.isHidden = !isEmpty
                vc.tableView.isHidden = isEmpty
            })
            .disposed(by: disposeBag)
        
        responsePlans
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: MeetPlanTableCell.reuseIdentifier, cellType: MeetPlanTableCell.self)) { [weak self] index, item, cell in
                
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
        
        responsePlans
            .asDriver(onErrorJustReturn: [])
            .map({ $0.count })
            .filter({ $0 > 0 })
            .drive(with: self, onNext: { vc, count in
                vc.countView.countText = "\(count)개"
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isLoading in
                vc.parentReactor?.action.onNext(.planLoading(isLoading))
            })
            .disposed(by: disposeBag)
    }
}

extension MeetPlanListViewController: UITableViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView.contentOffset.y < -60 else { return }
        reactor?.action.onNext(.requestPlanList)
    }
}



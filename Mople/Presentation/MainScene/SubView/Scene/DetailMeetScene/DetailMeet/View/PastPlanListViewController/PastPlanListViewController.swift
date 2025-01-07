//
//  PastPlanListViewController.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class PastPlanListViewController: UIViewController, View {

    typealias Reactor = PastPlanListViewReactor
    
    var disposeBag = DisposeBag()
    
    private var parentReactor: DetailMeetViewReactor?
    private var reviewCount: Int = 0
    
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
        return view
    }()
    
    init(reactor: PastPlanListViewReactor,
         parentReactor: DetailMeetViewReactor) {
        print(#function, #line, "LifeCycle Test PastPlanListViewController Created" )
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.parentReactor = parentReactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test PastPlanListViewController Deinit" )
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
            make.center.equalToSuperview()
            make.height.width.lessThanOrEqualTo(self.view)
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(PastPlanTableCell.self, forCellReuseIdentifier: PastPlanTableCell.reuseIdentifier)
        self.tableView.register(MeetPlanTableHeaderView.self, forHeaderFooterViewReuseIdentifier: MeetPlanTableHeaderView.reuseIdentifier)
    }
    
    func bind(reactor: PastPlanListViewReactor) {
        reactor.pulse(\.$reviews)
            .asDriver(onErrorJustReturn: [])
            .map({ $0.isEmpty })
            .drive(with: self, onNext: { vc, isEmpty in
                vc.emptyPlanView.isHidden = !isEmpty
                vc.tableView.isHidden = isEmpty
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$reviews)
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] reviews in
                self?.reviewCount = reviews.count
            })
            .drive(self.tableView.rx.items(cellIdentifier: PastPlanTableCell.reuseIdentifier, cellType: PastPlanTableCell.self)) { index, item, cell in
                cell.configure(viewModel: .init(review: item))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isLoading in
                print(#function, #line, "#33 isLoading : \(isLoading)" )
                vc.parentReactor?.action.onNext(.pastPlanLoading(isLoading))
            })
            .disposed(by: disposeBag)
    }
}

extension PastPlanListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MeetPlanTableHeaderView.reuseIdentifier) as! MeetPlanTableHeaderView
        header.setLabel(title: "지난 약속", count: reviewCount)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

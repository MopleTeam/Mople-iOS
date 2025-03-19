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

final class MeetReviewListViewController: BaseViewController, View {

    typealias Reactor = MeetReviewListViewReactor
    
    var disposeBag = DisposeBag()
    
    private var parentReactor: MeetDetailViewReactor?

    private lazy var countView: CountView = {
        let view = CountView(title: "지난 약속")
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: ColorStyle.Gray._04)
        view.setBottomInset(16)
        view.frame.size.height = 64
        return view
    }()
    
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
    
    init(reactor: MeetReviewListViewReactor,
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
        self.tableView.register(MeetReviewTableCell.self, forCellReuseIdentifier: MeetReviewTableCell.reuseIdentifier)
    }
    
    func bind(reactor: MeetReviewListViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
        setNotification(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        tableView.rx.itemSelected
            .map({ Reactor.Action.selectedReview(index: $0.row) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        let responsePlans = Observable.combineLatest(viewDidLayout, reactor.pulse(\.$reviews))
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
            .drive(self.tableView.rx.items(cellIdentifier: MeetReviewTableCell.reuseIdentifier, cellType: MeetReviewTableCell.self)) { index, item, cell in
                cell.configure(viewModel: .init(review: item))
                cell.selectionStyle = .none
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
                vc.parentReactor?.action.onNext(.reviewLoading(isLoading))
            })
            .disposed(by: disposeBag)
    }
    
    private func setNotification(_ reactor: Reactor) {
        EventService.shared.addReviewObservable()
            .map { Reactor.Action.updateReview($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

extension MeetReviewListViewController: UITableViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView.isRefresh() else { return }
        reactor?.action.onNext(.requestReviewList)
    }
}

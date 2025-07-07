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

    // MARK: - Reactor
    typealias Reactor = MeetReviewListViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let refresh: PublishSubject<Void> = .init()
    
    // MARK: - Variables
    private var hasAppeared: Bool = false
    
    // MARK: - UI Components
    private lazy var countView: CountView = {
        let view = CountView(title: L10n.Meetdetail.reviwelist)
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: .gray04)
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
        return table
    }()
    
    private let emptyReviewView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setTitle(text: L10n.Meetdetail.emptyPost)
        view.setImage(image: .emptyPlan)
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - LifeCycle
    init(reactor: MeetReviewListViewReactor) {
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
        self.view.addSubview(emptyReviewView)
        self.view.addSubview(tableView)
        
        emptyReviewView.snp.makeConstraints { make in
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
    
    private func setHeaderView() {
        guard hasAppeared == false else { return }
        hasAppeared = true
        tableView.tableHeaderView = countView
    }
    
    private func setReviewList(with reviewList: [Review]) {
        emptyReviewView.isHidden = !reviewList.isEmpty
        tableView.isHidden = reviewList.isEmpty
        setReviewCountLabel(count: reviewList.count)
    }
    
    private func setReviewCountLabel(count: Int) {
        guard count > 0 else { return }
        countView.countText = "\(count)개"
    }
}

extension MeetReviewListViewController: EdgeGestureConfigurable {
    func configureEdgeGesture(_ edgeGesture: UIGestureRecognizer) {
        tableView.panGestureRecognizer.require(toFail: edgeGesture)
    }
}

// MARK: - Reactor Setup
extension MeetReviewListViewController {
    
    func bind(reactor: MeetReviewListViewReactor) {
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
            .map({ Reactor.Action.selectedReview(index: $0.row) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refresh
            .map({ Reactor.Action.refresh })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setNotificationBind(_ reactor: Reactor) {
        NotificationManager.shared.addReviewObservable()
            .map { Reactor.Action.updateReview($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$reviews)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, reviewList in
                vc.setReviewList(with: reviewList)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$reviews)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: MeetReviewTableCell.reuseIdentifier, cellType: MeetReviewTableCell.self)) { index, item, cell in
                cell.configure(viewModel: .init(review: item))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
    }
}

extension MeetReviewListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.isRefresh() else { return }
        refresh.onNext(())
    }
}

//
//  PastPlanListViewController.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit
import Domain
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
    private let nextPage: PublishSubject<Void> = .init()
    
    // MARK: - Variables
    private var hasAppeared: Bool = false
    private var isSetEdgeGesture: Bool = false

    // 부모(MeetDetail)가 자식 스크롤을 추적해 헤더 sticky/hide를 처리할 수 있게 노출
    var onScrollChange: ((CGFloat) -> Void)?

    // 헤더 overlay 높이만큼 tableView 상단을 비워두는 inset. 부모가 layout 후 호출.
    // 헤더 height가 변동(공지 hidden ↔ visible)되면, 자식 contentOffset도 같은 delta만큼 따라 이동시켜
    // swipe 거리와 hide 거리가 항상 1:1로 매핑되게 한다.
    private var topInsetApplied: Bool = false
    func setTopContentInset(_ inset: CGFloat) {
        let oldInset = tableView.contentInset.top
        tableView.contentInset.top = inset
        tableView.verticalScrollIndicatorInsets.top = inset
        if !topInsetApplied {
            topInsetApplied = true
            tableView.setContentOffset(CGPoint(x: 0, y: -inset), animated: false)
            return
        }
        let delta = inset - oldInset
        guard abs(delta) > 0.5 else { return }
        let oldOffset = tableView.contentOffset.y
        tableView.setContentOffset(CGPoint(x: 0, y: oldOffset - delta), animated: false)
    }
    
    // MARK: - UI Components
    private lazy var countView: CountView = {
        let view = CountView(title: L10n.Meetdetail.reviwelist)
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: .text03)
        view.setMargin(inset: .init(top: 0, left: 20, bottom: 16, right: 20))
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
    
    private func setReviewList(with count: Int) {
        let hasPlan = count > 0
        emptyReviewView.isHidden = hasPlan
        tableView.isHidden = !hasPlan
        countView.countText = "\(count)개"
    }
}

extension MeetReviewListViewController: EdgeGestureConfigurable {
    func configureEdgeGesture(_ edgeGesture: UIGestureRecognizer) {
        guard !isSetEdgeGesture else { return }
        tableView.panGestureRecognizer.require(toFail: edgeGesture)
        isSetEdgeGesture = true
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
        
        nextPage
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .map({ Reactor.Action.fetchNextReview })
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
        reactor.pulse(\.$totolPlanCount)
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self, onNext: { vc, count in
                print(#function, #line, "Path : #1 \(count) ")
                vc.setReviewList(with: count)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 부모 헤더 sticky/hide 처리용 offset 전달
        onScrollChange?(scrollView.contentOffset.y)

        guard scrollView.isBottom(threshold: 50),
              reactor?.page?.hasNext == true else { return }
        nextPage.onNext(())
    }
}

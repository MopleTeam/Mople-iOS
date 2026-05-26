//
//  FuturePlanListViewController.swift
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

final class MeetPlanListViewController: BaseViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = MeetPlanListViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let participation: PublishSubject<(id: Int,
                                               isJoin: Bool)> = .init()
    private let refresh: PublishSubject<Void> = .init()
    private let nextPage: PublishSubject<Void> = .init()
    
    // MARK: - Variables
    private var hasAppeared: Bool = false
    private var isVisibleView: Bool = false
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
    private let countView: CountView = {
        let view = CountView(title: L10n.Meetdetail.planlist)
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: .text03)
        view.setMargin(inset: .init(top: 0, left: 20, bottom: 16, right: 20))
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
        // 페이지 전환으로 다시 표시될 때 부모(MeetDetail)의 헤더 transform이 이전 자식의 상태로
        // stale일 수 있다. 자기 contentOffset.y를 즉시 알려서 헤더 transform을 재계산하게 한다.
        onScrollChange?(tableView.contentOffset.y)
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
    
    private func setPlanList(with count: Int) {
        let hasPlan = count > 0
        emptyPlanView.isHidden = hasPlan
        tableView.isHidden = !hasPlan
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
                                                       isJoin: $0.isJoin) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextPage
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .map({ Reactor.Action.fetchNextPlan })
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
        reactor.pulse(\.$totolPlanCount)
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self, onNext: { vc, count in
                vc.setPlanList(with: count)
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
                                                  isJoin: item.isParticipation)
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
}

extension MeetPlanListViewController: EdgeGestureConfigurable {
    func configureEdgeGesture(_ edgeGesture: UIGestureRecognizer) {
        guard !isSetEdgeGesture else { return }
        tableView.panGestureRecognizer.require(toFail: edgeGesture)
        isSetEdgeGesture = true
    }
}

// MARK: - Handle Plan Participation
extension MeetPlanListViewController {
    
    /// 일정 참여 핸들링
    private func handleParticipationPlan(id: Int, isJoin: Bool) {
        if !isJoin {
            participation.onNext((id, true))
        } else {
            showLeavePlanAlert(id: id)
        }
    }
    
    
    /// 일정 떠나기 알림
    /// - Parameter id: 일정 ID
    private func showLeavePlanAlert(id: Int) {
        let createAction: DefaultAlertAction = .init(text: L10n.yes,
                                                     textColor: .secondaryText,
                                                     bgColor: .appSecondary,
                                                     completion: { [weak self] in
            self?.participation.onNext((id, false))
        })
        
        alertManager.showDefaultAlert(title: L10n.Meetdetail.planLeaveInfo,
                                      defaultAction: .init(text: L10n.cancle,
                                                           textColor: .tertiaryText,
                                                           bgColor: .appTertiary),
                                      addAction: [createAction])
    }
}

extension MeetPlanListViewController: UIScrollViewDelegate {
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

//
//  EventTableViewController.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

final class PostListViewController: BaseViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = PostListViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private var dataSource: RxTableViewSectionedReloadDataSource<PostListSectionModel>?
    private var visibleHeaders: [UIView] = []
    private var saveOffsetY: CGFloat = 0
    private let tableHeaderHeight: CGFloat = 28

    // MARK: - Observable
    private let dateSyncObserver: PublishRelay<Date> = .init()
    private let scrollEndObserver: PublishRelay<ScheduleFetchType?> = .init()
    private let userInteratingObserver: BehaviorRelay<Bool> = .init(value: false)
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.sectionHeaderTopPadding = 0
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = true
        table.sectionFooterHeight = 8
        return table
    }()

    private let emptyPostView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setTitle(text: L10n.Calendar.empty)
        view.setImage(image: .emptyPlan)
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTableviewScroll()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setupTableView()
    }
    
    private func setLayout() {
        self.view.backgroundColor = .bgPrimary
        view.addSubview(tableView)
        view.addSubview(emptyPostView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyPostView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalTo(self.view.safeAreaLayoutGuide).priority(.high)
        }
    }
    
    private func setupTableView() {
        tableView.tableHeaderView = UIView(frame: .init(x: 0,
                                                        y: 0,
                                                        width: tableView.bounds.width,
                                                        height: tableHeaderHeight))
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(PostListTableCell.self, forCellReuseIdentifier: PostListTableCell.reuseIdentifier)
        self.tableView.register(PostListTableHeaderView.self, forHeaderFooterViewReuseIdentifier: PostListTableHeaderView.reuseIdentifier)
    }
    
    private func makeDataSource() -> RxTableViewSectionedReloadDataSource<PostListSectionModel> {
        dataSource = RxTableViewSectionedReloadDataSource<PostListSectionModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: PostListTableCell.reuseIdentifier) as! PostListTableCell
                cell.configure(viewModel: .init(post: item))
                cell.selectionStyle = .none
                return cell
            }
        )
        
        return dataSource!
    }
}

// MARK: - Reactor Setup
extension PostListViewController {
    func bind(reactor: PostListViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
    }
    
    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        self.dateSyncObserver
            .filter({ [weak self] _ in
                self?.userInteratingObserver.value == true
            })
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.childEvent(.scrollToDate($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        self.scrollEndObserver
            .throttle(.seconds(1),
                      latest: false,
                      scheduler: MainScheduler.instance)
            .compactMap({ $0 })
            .map { Reactor.Action.getMorePost($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected
            .compactMap({ [weak self] indexPath -> Reactor.Action? in
                guard let selectedPlan = self?.findSelctedPlan(at: indexPath) else { return nil }
                return .childEvent(.selectedPost(selectedPlan))
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$postList)
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] test in
                self?.saveOffsetY = self?.tableView.contentOffset.y ?? 0
            })
            .map { [PostListSectionModel].makeSectionModels(list: $0) }
            .drive(tableView.rx.items(dataSource: makeDataSource())) // 강한참조 확인필요
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$postList)
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, hasPlan in
                vc.tableView.isHidden = !hasPlan
                vc.emptyPostView.isHidden = hasPlan
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$previousPostList)
            .filter({ $0.isEmpty == false })
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, sectionList in
                vc.adjustOffsetWhenUpdatePost(list: sectionList)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$reset)
            .compactMap { $0 }
            .subscribe(with: self, onNext: { vc, _ in
                vc.visibleHeaders.removeAll()
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedDate)
            .filter({ [weak self] _ in
                self?.userInteratingObserver.value == false
            })
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, selectDate in
                vc.scrollSelectedDate(selectDate)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Table Delegate
extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 203
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PostListTableHeaderView.reuseIdentifier) as! PostListTableHeaderView
        let title = dataSource?[section].title
        header.setTitle(title: title, tag: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 203
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.visibleHeaders.append(view)
        self.visibleHeaders.sort { $0.tag < $1.tag }
        shouldRequestMoreData(for: section)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        self.visibleHeaders.removeAll { $0.tag == view.tag }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        userInteratingObserver.accept(true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        userInteratingObserver.accept(false)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        handleIsUserInteractingWithVelocity(velocity)
    }
    
    private func handleIsUserInteractingWithVelocity(_ velocity: CGPoint) {
        guard velocity.y == 0 else { return }
        userInteratingObserver.accept(false)
    }
}

// MARK: - Scroll Delegate
extension PostListViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleScrollForSyncDate(scrollView)
        handleScrollForDataLoad(scrollView)
    }

    private func handleScrollForSyncDate(_ scrollView: UIScrollView) {
        if scrollView.isBottom() {
            syncIfLastContent()
        } else {
            syncIfCrossedCenterLine()
        }
    }
    
    /// 유저의 액션일 때만 willDisplayHeaderView로 데이터를 추가하고 있는 상황
    /// 특정 조건에 의해 Y의 첫 지점 또는 마지막 지점으로 시스템 이동
    /// - 유저의 이동이 아님으로 데이터를 추가로 받아오지 않음
    /// 이를 방지하기 위해 willDisplayHeaderView와 별개로 추가 요청
    /// `scrollViewDidScroll`에서 Y 지점을 판단하여 데이터를 요청함
    private func handleScrollForDataLoad(_ scrollView: UIScrollView) {
        if scrollView.isRefresh(threshold: -20) {
            addPreviousPlan()
        } else if scrollView.isBottom(threshold: -20) {
            addNextPlan()
        }
    }
}

// MARK: - 추가 데이터 상태 및 요청
extension PostListViewController {
    private func shouldRequestMoreData(for section: Int) {
        guard let sectionCount = dataSource?.sectionModels.count else { return }
        if section == 1 {
            addPreviousPlan()
        } else if sectionCount == section + 1 {
            addNextPlan()
        }
    }
    
    private func addNextPlan() {
        guard canLoadMore(loadState: .next) else { return }
        scrollEndObserver.accept(.next)
    }
    
    private func addPreviousPlan() {
        guard canLoadMore(loadState: .previous) else { return }
        scrollEndObserver.accept(.previous)
    }
    
    private func canLoadMore(loadState: LoadState) -> Bool {
        guard userInteratingObserver.value else { return false }
        
        switch reactor?.loadState {
        case .all, loadState:
            return true
        default:
            return false
        }
    }
}

// MARK: - 테이블뷰 IndexPath 조정
extension PostListViewController {
    
    /// 캘린더에서 선택된 날짜에 맞추어 테이블뷰의 IndexPath 조정
    /// - Parameter selectDate: 캘린더에서 넘어온 날짜 및 IndexPath로 Scroll시 Animate 유무
    private func scrollSelectedDate(_ selectDate: Date) {
        guard let models = dataSource?.sectionModels else { return }
        guard let headerIndex = models.firstIndex(where: {
            guard let sectionDate = $0.date else { return false }
            return DateManager.isSameDay(sectionDate, selectDate)
        }) else { return }
        tableView.scrollToRow(at: .init(row: 0, section: headerIndex), at: .middle, animated: false)
    }
    
    private func adjustOffsetWhenUpdatePost(list: [MonthlyPost]) {
        let addSectionCount = Set(list.compactMap({ $0.date })
            .map({ DateManager.startOfDay($0) }))
            .count
        
        tableView.scrollToRow(at: .init(row: 0, section: addSectionCount),
                                 at: .top,
                                 animated: false)
        
        tableView.contentOffset.y += saveOffsetY - tableHeaderHeight
    }
}

// MARK: - Point Check
extension PostListViewController {
    private func checkCenterPoint(targetPoint: Double) -> Bool {
        let center = self.view.frame.height / 2
        return center > targetPoint
    }
}

// MARK: - 리스트에 표시된 일정 캘린더에게 공유
extension PostListViewController {
    
    private func syncIfCrossedCenterLine() {
        guard let topHeader = visibleHeaders.first,
              let topHeaderFrame = topHeader.superview?.convert(topHeader.frame, to: self.view),
              checkCenterPoint(targetPoint: topHeaderFrame.origin.y),
              let foucsDate = dataSource?[topHeader.tag].date else { return }

        dateSyncObserver.accept(foucsDate)
    }
    
    private func syncIfLastContent() {
        guard let lastComponents = dataSource?.sectionModels.last?.date else { return }
        dateSyncObserver.accept(lastComponents)
    }
}

// MARK: - Gesture
extension PostListViewController {
    public func panGestureRequire(_ gesture: UIPanGestureRecognizer) {
        self.tableView.panGestureRecognizer.require(toFail: gesture)
    }
}

// MARK: - Helper
extension PostListViewController {
    private func findSelctedPlan(at indexPath: IndexPath) -> MonthlyPost? {
        guard let section = dataSource?.sectionModels[indexPath.section],
              let item = section.items[safe: indexPath.row] else { return nil }
        return item
    }
    
    public func checkTop() -> Bool {
        return self.tableView.contentOffset.y <= self.tableView.contentInset.top
    }
    
    private func stopTableviewScroll() {
        guard tableView.isDragging else { return }
        let currentOffset = tableView.contentOffset
        tableView.setContentOffset(currentOffset, animated: false)
    }
}

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

final class ScheduleListViewController: BaseViewController, View {
    
    typealias Reactor = ScheduleListReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private var dataSource: RxTableViewSectionedReloadDataSource<ScheduleListSectionModel>?
    private var visibleHeaders: [UIView] = []
    private var saveOffsetY: CGFloat = 0
    private let nextLoadState: [LoadState] = [.all, .next]
    private let previousLoadStaet: [LoadState] = [.all, .previous]

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
        table.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: table.bounds.width, height: 28))
        return table
    }()

    private let emptyPlanView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setTitle(text: TextStyle.Calendar.emptyTitle)
        view.setImage(image: .emptyPlan)
        view.hideContent(true)
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
        initalSetup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTableviewScroll()
    }
    
    private func initalSetup() {
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setupTableView()
    }
    
    private func setLayout() {
        self.view.backgroundColor = .clear
        view.addSubview(tableView)
                
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(ScheduleListTableCell.self, forCellReuseIdentifier: ScheduleListTableCell.reuseIdentifier)
        self.tableView.register(ScheduleListTableHeaderView.self, forHeaderFooterViewReuseIdentifier: ScheduleListTableHeaderView.reuseIdentifier)
    }
    
    private func makeDataSource() -> RxTableViewSectionedReloadDataSource<ScheduleListSectionModel> {
        dataSource = RxTableViewSectionedReloadDataSource<ScheduleListSectionModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleListTableCell.reuseIdentifier) as! ScheduleListTableCell
                cell.configure(viewModel: .init(testPlan: item))
                cell.selectionStyle = .none
                return cell
            }
        )
        
        return dataSource!
    }
    
    // MARK: - Bind
    func bind(reactor: ScheduleListReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func outputBind(_ reactor: Reactor) {
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
            .map { Reactor.Action.getMorePlan($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected
            .compactMap({ [weak self] indexPath -> Reactor.Action? in
                guard let selectedPlan = self?.findSelctedPlan(at: indexPath) else { return nil }
                return .childEvent(.selectedPlan(selectedPlan))
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func findSelctedPlan(at indexPath: IndexPath) -> MonthlyPlan? {
        guard let section = dataSource?.sectionModels[indexPath.section],
              let item = section.items[safe: indexPath.row] else { return nil }
        return item
    }
    
    private func inputBind(_ reactor: Reactor) {
        reactor.pulse(\.$planList)
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] _ in
                self?.saveOffsetY = self?.tableView.contentOffset.y ?? 0
            })
            .map { [ScheduleListSectionModel].makeSectionModels(list: $0) }
            .drive(tableView.rx.items(dataSource: makeDataSource())) // 강한참조 확인필요
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$addPlanList)
            .filter({ $0.isEmpty == false })
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, sectionList in
                vc.adjustNewPlanListHeight(list: sectionList)
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
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, selectDate in
                vc.scrollSelectedDate(selectDate)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Table Delegate
extension ScheduleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 203
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ScheduleListTableHeaderView.reuseIdentifier) as! ScheduleListTableHeaderView
        let title = dataSource?[section].title
        header.setTitle(title: title, tag: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    #warning("데이터가 리셋된 다음 특정 위치로 y지점 변경 후 위로 스크롤 시 셀의 높이가 조정되면서 컨텐츠 사이즈가 변경됨 이를 방지하기 위해 기본높이를 지정")
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
extension ScheduleListViewController {

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
extension ScheduleListViewController {
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
extension ScheduleListViewController {
    
    /// 캘린더에서 선택된 날짜에 맞추어 테이블뷰의 IndexPath 조정
    /// - Parameter selectDate: 캘린더에서 넘어온 날짜 및 IndexPath로 Scroll시 Animate 유무
    private func scrollSelectedDate(_ selectDate: Date) {
        print(#function, #line, "#0318 들어온 날짜 : \(selectDate)" )
        guard let models = dataSource?.sectionModels else { return }
        guard let headerIndex = models.firstIndex(where: { $0.date == selectDate }) else { return }
        tableView.scrollToRow(at: .init(row: 0, section: headerIndex), at: .middle, animated: false)
    }
    
    private func adjustNewPlanListHeight(list: [MonthlyPlan]) {
        let addSectionCount = Set(list.compactMap({ $0.date })
            .map({ DateManager.startOfDay($0) }))
            .count
        
        tableView.scrollToRow(at: .init(row: 0, section: addSectionCount),
                                 at: .top,
                                 animated: false)
        
        tableView.contentOffset.y += saveOffsetY - 28
    }
}

// MARK: - Point Check
extension ScheduleListViewController {
    private func checkNearBottom(scrollView: UIScrollView,
                                 threshold: CGFloat = 50) -> Bool {
        let tabbarHeight = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomThreshold = tabbarHeight - threshold
        return scrollView.isBottom(threshold: -bottomThreshold)
    }
    
    private func checkCenterPoint(targetPoint: Double) -> Bool {
        let center = self.view.frame.height / 2
        let tabHeight = self.tabBarController?.tabBar.frame.height ?? 0
        let contentCenter = center - tabHeight
        return contentCenter > targetPoint
    }
}

// MARK: - 리스트에 표시된 일정 캘린더에게 공유
extension ScheduleListViewController {
    
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
extension ScheduleListViewController {
    #warning("다시 한번 알아두기")
    public func panGestureRequire(_ gesture: UIPanGestureRecognizer) {
        self.tableView.panGestureRecognizer.require(toFail: gesture)
    }
}

// MARK: - Helper
extension ScheduleListViewController {
    public func checkTop() -> Bool {
        return self.tableView.contentOffset.y <= self.tableView.contentInset.top
    }
    
    private func stopTableviewScroll() {
        guard tableView.isDragging else { return }
        let currentOffset = tableView.contentOffset
        tableView.setContentOffset(currentOffset, animated: false)
    }
}

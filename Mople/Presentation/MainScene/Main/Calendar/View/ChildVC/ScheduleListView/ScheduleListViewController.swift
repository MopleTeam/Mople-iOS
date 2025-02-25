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
    // isSystemDragging 주간 달력을 넘기거나, 선택 시 스크롤 애니메이션(true)로 진행되는데 이 때, 스크롤 되면서 선택되는 것을 방지하기 위함
    private var isUserDragging = false
    private var dataSource: RxTableViewSectionedReloadDataSource<ScheduleListSectionModel>?
    private var visibleHeaders: [UIView] = []

    // MARK: - Observable
    private let dateSyncObserver: PublishRelay<Date> = .init()
    private let userInteractingObserver: BehaviorRelay<Bool> = .init(value: false)
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.sectionHeaderTopPadding = 0
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
        reactor.pulse(\.$planList)
            .map { [weak self] planList -> [ScheduleListSectionModel] in
                guard let self else { return [] }
                return makeSectionModels(list: planList)
            }
            .asDriver(onErrorJustReturn: [])
            .filter({ $0.isEmpty == false })
            .drive(tableView.rx.items(dataSource: makeDataSource())) // 강한참조 확인필요
            .disposed(by: disposeBag)
        
        self.dateSyncObserver
            .pairwise()
            .filter({ $0 != $1 })
            .map({ $1 })
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.childEvent(.scrollToDate($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
//        
//        self.userInteractingObserver
//            .observe(on: MainScheduler.instance)
//            .map { Reactor.Action.tableViewInteracting(isScroll: $0) }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//        
//        // 테이블뷰 스크롤 시 캘린더에서 선택되는 날짜들이 다시 테이블로 넘어오는 것을 방지
        self.tableView.rx.willBeginDragging
            .subscribe(with: self, onNext: { vc, _ in
                vc.isUserDragging = true
            })
            .disposed(by: disposeBag)
//            .do(onNext: { [weak self] _ in
//                self?.isSystemDragging = false
//            })
//            .map({ _ in true })
//            .asDriver(onErrorJustReturn: true)
//            .drive(userInteractingObserver)
//            .disposed(by: disposeBag)
//        
        self.tableView.rx.didEndDecelerating
            .subscribe(with: self, onNext: { vc, _ in
                vc.isUserDragging = false
            })
            .disposed(by: disposeBag)
//            .map({ _ in false })
//            .asDriver(onErrorJustReturn: false)
//            .drive(userInteractingObserver)
//            .disposed(by: disposeBag)
    }
    
    private func makeSectionModels(list: [MonthlyPlan]) -> [ScheduleListSectionModel] {
        let grouped = Dictionary(grouping: list) { plan -> Date? in
            guard let date = plan.date else { return nil }
            return DateManager.startOfDay(date)
        }
        
        let sorted = grouped.sorted { first, second in
            guard let firstDate = first.key,
                  let secondDate = second.key else { return false }
            return firstDate < secondDate
        }
        
        return sorted.map { ScheduleListSectionModel(date: $0.key, items: $0.value) }
    }
    
    #warning("데이터 받을 때 layoutsubviews 신경쓰기")
    private func inputBind(_ reactor: Reactor) {
//        reactor.pulse(\.$schedules)
//            .asDriver(onErrorJustReturn: [])
//            .drive(tableView.rx.items(dataSource: dataSource!))
//            .disposed(by: disposeBag)
//        
//        reactor.pulse(\.$schedules)
//            .map({ $0.isEmpty })
//            .observe(on: MainScheduler.instance)
//            .asDriver(onErrorJustReturn: false)
//            .drive(with: self, onNext: { vc, isEmpty in
//                vc.tableView.isHidden = isEmpty
//                vc.emptyPlanView.isHidden = !isEmpty
//            })
//            .disposed(by: disposeBag)
//        
        reactor.pulse(\.$selectedDate)
            .filter({ [weak self] _ in
                return self?.isUserDragging == false
            })
            .debounce(.milliseconds(10), scheduler: MainScheduler.instance)
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

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.visibleHeaders.append(view)
        self.visibleHeaders.sort { $0.tag < $1.tag }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        self.visibleHeaders.removeAll { $0.tag == view.tag }
    }
}

// MARK: - Scroll Delegate
extension ScheduleListViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isUserDragging else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if checkNearBottom(offsetY: offsetY, contentHeight: contentHeight) {
            notifyIfLastContent()
        } else {
            notifyIfCrossedCenterLine()
        }
    }
}

// MARK: - 테이블 뷰 화면 표시
extension ScheduleListViewController {
    public func updateConstraints(isHide: Bool) {
        if tableView.isHidden == false {
            remakeTableView(isHide)
        } else {
            emptyPlanView.hideContent(isHide)
        }
    }
    
    private func remakeTableView(_ isHide: Bool) {
        tableView.snp.remakeConstraints(isHide ? hideTableView(_:) : showTableView(_:))
    }
    
    private func hideTableView(_ make: ConstraintMaker) {
        make.horizontalEdges.equalToSuperview()
        make.bottom.equalToSuperview()
        make.top.equalTo(self.view.snp.bottom)
    }
    
    private func showTableView(_ make: ConstraintMaker) {
        make.edges.equalToSuperview()
    }
}

// MARK: - 테이블뷰 IndexPath 조정
extension ScheduleListViewController {
    
    /// 캘린더에서 선택된 날짜에 맞추어 테이블뷰의 IndexPath 조정
    /// - Parameter selectDate: 캘린더에서 넘어온 날짜 및 IndexPath로 Scroll시 Animate 유무
    private func scrollSelectedDate(_ selectDate: Date) {
        guard let models = dataSource?.sectionModels else { return }
        guard let headerIndex = models.firstIndex(where: { $0.date == selectDate }) else { return }
        tableView.scrollToRow(at: .init(row: 0, section: headerIndex), at: .middle, animated: false)
    }
}

// MARK: - Point Check
extension ScheduleListViewController {
    private func checkNearBottom(offsetY: CGFloat, contentHeight: CGFloat, threshold: CGFloat = 50) -> Bool {
        
        let tabbarHeight = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomEdge = offsetY + self.view.frame.height - tabbarHeight + threshold
        return bottomEdge > contentHeight
    }
    
    private func centerPoint(targetPoint: Double) -> Bool {
        let center = self.view.frame.height / 2
        let tabHeight = self.tabBarController?.tabBar.frame.height ?? 0
        let contentCenter = center - tabHeight
        return contentCenter > targetPoint
    }
}

// MARK: - Notify Calendar
extension ScheduleListViewController {
    
    private func notifyIfCrossedCenterLine() {
        guard let topHeader = visibleHeaders.first,
              let topHeaderFrame = topHeader.superview?.convert(topHeader.frame, to: self.view),
              centerPoint(targetPoint: topHeaderFrame.origin.y),
              let foucsDate = dataSource?[topHeader.tag].date else { return }

        dateSyncObserver.accept(foucsDate)
    }
    
    private func notifyIfLastContent() {
        guard let lastComponents = dataSource?.sectionModels.last?.date,
              let sectionCount = dataSource?.sectionModels.count else { return }
        
        switch sectionCount {
        case ...2:
            guard self.visibleHeaders.count <= 1 else { break }
            dateSyncObserver.accept(lastComponents)
        default:
            dateSyncObserver.accept(lastComponents)
        }
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
        self.userInteractingObserver.accept(false)
        guard tableView.isDragging else { return }
        let currentOffset = tableView.contentOffset
        tableView.setContentOffset(currentOffset, animated: false)
    }
}

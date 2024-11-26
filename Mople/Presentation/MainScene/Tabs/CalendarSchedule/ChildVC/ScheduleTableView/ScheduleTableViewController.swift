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

final class ScheduleTableViewController: UIViewController, View {
    
    typealias Reactor = CalendarViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    // isSystemDragging 주간 달력을 넘기거나, 선택 시 스크롤 애니메이션(true)로 진행되는데 이 때, 스크롤 되면서 선택되는 것을 방지하기 위함
    private var isSystemDragging = false
    private var dataSource: RxTableViewSectionedReloadDataSource<ScheduleTableSectionModel>?
    private var sectionModels: [ScheduleTableSectionModel] = []
    private var visibleHeaders: [UIView] = []

    // MARK: - Observable
    private let dateSyncObserver: PublishRelay<Date?> = .init()
    private let userInteractingObserver: BehaviorRelay<Bool> = .init(value: false)
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        #warning("섹션 헤더 sticky 되는 현상 막기")
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.sectionFooterHeight = 8
        table.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: table.bounds.width, height: 28))
        return table
    }()

    private let emptyScheduleView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setTitle(text: TextStyle.Calendar.emptyTitle)
        view.setImage(image: .emptySchedule)
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - LifeCycle
    init(reactor: Reactor) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
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
        view.addSubview(emptyScheduleView)
        
        emptyScheduleView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.bottom)
        }
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        self.tableView.register(SchedulTableHeaderView.self, forHeaderFooterViewReuseIdentifier: SchedulTableHeaderView.reuseIdentifier)
    }
    
    private func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<ScheduleTableSectionModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier) as! ScheduleTableViewCell
                cell.configure(viewModel: .init(schedule: item))
                cell.selectionStyle = .none
                return cell
            }
        )
    }
    
    // MARK: - Bind
    func bind(reactor: CalendarViewReactor) {
        setupDataSource()
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func outputBind(_ reactor: Reactor) {
        self.dateSyncObserver
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.sharedTableViewDate(date: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.userInteractingObserver
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.tableViewInteracting(isScroll: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 테이블뷰 스크롤 시 캘린더에서 선택되는 날짜들이 다시 테이블로 넘어오는 것을 방지
        self.tableView.rx.willBeginDragging
            .do(onNext: { _ in self.isSystemDragging = false })
            .map({ _ in true })
            .asDriver(onErrorJustReturn: true)
            .drive(userInteractingObserver)
            .disposed(by: disposeBag)
        
        self.tableView.rx.didEndDecelerating
            .map({ _ in false })
            .asDriver(onErrorJustReturn: false)
            .drive(userInteractingObserver)
            .disposed(by: disposeBag)
    }
    
    private func inputBind(_ reactor: Reactor) {
        reactor.pulse(\.$schedules)
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$schedules)
            .map({ $0.isEmpty })
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isEmpty in
                vc.tableView.isHidden = isEmpty
                vc.emptyScheduleView.isHidden = !isEmpty
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedDate)
            .compactMap { $0 }
            .debounce(.milliseconds(10), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, selectDate in
                vc.scrollSelectedDate(selectDate)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Table Delegate
extension ScheduleTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 203
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SchedulTableHeaderView.reuseIdentifier) as! SchedulTableHeaderView
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
extension ScheduleTableViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isSystemDragging else { return }
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
extension ScheduleTableViewController {
    public func remakeConstraints(isHide: Bool) {
        if !tableView.isHidden {
            remakeTableView(isHide)
        } else {
            remakeEmptyView(isHide)
        }
    }
    
    private func remakeTableView(_ isHide: Bool) {
        guard !tableView.isHidden else { return }
        tableView.snp.remakeConstraints(isHide ? hideView(_:) : showTableView(_:))
    }
    
    private func remakeEmptyView(_ isHide: Bool) {
        guard !emptyScheduleView.isHidden else { return }
        emptyScheduleView.snp.remakeConstraints(isHide ? hideView(_:) : showEmptyView(_:))
    }
    
    private func hideView(_ make: ConstraintMaker) {
        make.horizontalEdges.equalToSuperview()
        make.bottom.equalToSuperview()
        make.top.equalTo(self.view.snp.bottom)
    }
    
    private func showTableView(_ make: ConstraintMaker) {
        make.edges.equalToSuperview()
    }
    
    private func showEmptyView(_ make: ConstraintMaker) {
        make.horizontalEdges.equalToSuperview()
        make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        make.top.equalTo(self.view.snp.top)
    }
}

// MARK: - 테이블뷰 IndexPath 조정
extension ScheduleTableViewController {
    
    /// 캘린더에서 선택된 날짜에 맞추어 테이블뷰의 IndexPath 조정
    /// - Parameter selectDate: 캘린더에서 넘어온 날짜 및 IndexPath로 Scroll시 Animate 유무
    private func scrollSelectedDate(_ selectDate: CalendarViewController.SelectDate) {
        guard let models = dataSource?.sectionModels else { return }
        guard let headerIndex = models.firstIndex(where: { $0.date == selectDate.selectedDate }) else { return }
        isSystemDragging = true
        tableView.scrollToRow(at: .init(row: 0, section: headerIndex), at: .middle, animated: selectDate.isScroll)
    }
}

// MARK: - Point Check
extension ScheduleTableViewController {
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
extension ScheduleTableViewController {
    
    private func notifyIfCrossedCenterLine() {
        guard let topHeader = visibleHeaders.first,
              let topHeaderFrame = topHeader.superview?.convert(topHeader.frame, to: self.view),
              centerPoint(targetPoint: topHeaderFrame.origin.y) else { return }
        
        let foucsDate = dataSource?[topHeader.tag].date
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
extension ScheduleTableViewController {
    #warning("다시 한번 알아두기")
    public func panGestureRequire(_ gesture: UIPanGestureRecognizer) {
        self.tableView.panGestureRecognizer.require(toFail: gesture)
    }
}

// MARK: - Helper
extension ScheduleTableViewController {
    public func checkTop() -> Bool {
        print(#function, #line, "top : \(self.tableView.contentOffset.y <= self.tableView.contentInset.top)" )
        return self.tableView.contentOffset.y <= self.tableView.contentInset.top
    }
    
    private func stopTableviewScroll() {
        self.userInteractingObserver.accept(false)
        guard tableView.isDragging else { return }
        let currentOffset = tableView.contentOffset
        tableView.setContentOffset(currentOffset, animated: false)
    }
}

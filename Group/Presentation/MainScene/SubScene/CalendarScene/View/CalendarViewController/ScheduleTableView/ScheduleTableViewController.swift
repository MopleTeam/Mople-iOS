//
//  EventTableViewController.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import RxDataSources

final class ScheduleTableViewController: UIViewController {
    
    typealias Section = SectionModel<DateComponents, Schedule>
    
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private var systemIsDragging = false
    private var dataSource: RxTableViewSectionedReloadDataSource<ScheduleTableModel>?
    private var visibleHeaders: [UIView] = []
    
    // MARK: - Observable
    private let fetchDataObservable: Observable<[ScheduleTableModel]>
    private let dateObervable: AnyObserver<DateComponents>
    private let foucsCellObservable: Observable<DateComponents>
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        
        #warning("섹션 헤더 sticky 되는 현상 막기")
        let table = UITableView(frame: .zero, style: .grouped)
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.sectionFooterHeight = 8
        table.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: table.bounds.width, height: 28))
        return table
    }()
    
    // MARK: - LifeCycle
    init(fetchDataObservable: Observable<[ScheduleTableModel]>,
         dateObservable: AnyObserver<DateComponents>,
         foucsCellObservable: Observable<DateComponents>) {
        self.fetchDataObservable = fetchDataObservable
        self.dateObervable = dateObservable
        self.foucsCellObservable = foucsCellObservable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        setBinding()
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
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        self.tableView.register(SchedulTableHeaderView.self, forHeaderFooterViewReuseIdentifier: SchedulTableHeaderView.reuseIdentifier)
    }
    
    // MARK: - Bind
    private func setBinding() {
        dataSource = RxTableViewSectionedReloadDataSource<ScheduleTableModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier) as? ScheduleTableViewCell else { return UITableViewCell() }
                
                cell.configure(viewModel: .init(schedule: item))
                cell.selectionStyle = .none
                
                return cell
            }
        )
        
        fetchDataObservable
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        #warning("시스템이 스크롤하는 것과 유저가 스크롤 하는 것 구분 하는 법 정리하기")
        foucsCellObservable
            .subscribe(with: self, onNext: { vc, foucsDate in
                guard let models = vc.dataSource?.sectionModels else { return }
                guard let headerIndex = models.firstIndex(where: { $0.dateComponents == foucsDate }) else { return }
                vc.systemIsDragging = true
                vc.tableView.scrollToRow(at: .init(row: 0, section: headerIndex), at: .middle, animated: false)
            })
            .disposed(by: disposeBag)
    }
}

extension ScheduleTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 203
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SchedulTableHeaderView.reuseIdentifier) as? SchedulTableHeaderView else {
            return nil
        }
        
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

// MARK: - Delegate
extension ScheduleTableViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !systemIsDragging else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if checkNearBottom(offsetY: offsetY, contentHeight: contentHeight) {
            notifyIfLastContent()
        } else {
            notifyIfCrossedCenterLine()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        systemIsDragging = false
    }
}

// MARK: - 테이블 뷰 화면 표시
extension ScheduleTableViewController {
    public func hideView(isHide: Bool) {
        if isHide {
            tableView.snp.remakeConstraints { make in
                make.horizontalEdges.equalToSuperview()
                make.bottom.equalToSuperview()
                make.top.equalTo(self.view.snp.bottom)
            }
        } else {
            tableView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

// MARK: - Point Check
extension ScheduleTableViewController {
    private func checkNearBottom(offsetY: CGFloat, contentHeight: CGFloat, threshold: CGFloat = 0) -> Bool {
        let bottomEdge = offsetY + self.view.frame.height + threshold
        
        return bottomEdge > contentHeight
    }
    
    private func centerPoint() -> CGFloat {
        let centerPoint = self.view.frame.height / 2
        let tabHeight = self.tabBarController?.tabBar.frame.height ?? 0
        return centerPoint - tabHeight
    }
}

// MARK: - Notify Calendar
extension ScheduleTableViewController {
    
    private func notifyIfCrossedCenterLine() {
        guard let topHeader = visibleHeaders.first,
              let topHeaderFrame = topHeader.superview?.convert(topHeader.frame, to: self.view),
              centerPoint() > topHeaderFrame.origin.y,
              let dataSource = dataSource else { return }
        
        let components = dataSource[topHeader.tag].dateComponents
        dateObervable.onNext(components)
    }
    
    private func notifyIfLastContent() {
        guard let lastComponents = dataSource?.sectionModels.last?.dateComponents else { return }
        dateObervable.onNext(lastComponents)
    }
}

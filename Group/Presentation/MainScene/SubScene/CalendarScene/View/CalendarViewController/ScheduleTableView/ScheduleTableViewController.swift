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
    
    var isDragging = false
    
    private var systemIsDragging = false {
        didSet {
            guard systemIsDragging else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: {
                self.systemIsDragging = false
            })
        }
    }
    
    private let fetchDataObservable: Observable<[ScheduleTableModel]>
    private let dateObervable: AnyObserver<DateComponents>
    private let foucsCellObservable: Observable<DateComponents>
    
    private var dataSource: RxTableViewSectionedReloadDataSource<ScheduleTableModel>?
    
    private var visibleHeaders: [UIView] = []
    
    private let tableView: UITableView = {
        
        #warning("섹션 헤더 sticky 되는 현상 막기")
        let table = UITableView(frame: .zero, style: .grouped)
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.sectionFooterHeight = 8
    
        let headerView = UIView(frame: .init(x: 0, y: 0, width: table.bounds.width, height: 28))
        table.tableHeaderView = headerView
        
        table.clipsToBounds = true
        return table
    }()
    
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
    
    private func setupUI() {
        setLayout()
        setupTableView()
    }
    
    private func setLayout() {
        self.view.backgroundColor = .clear
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.bottom)
        }
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        self.tableView.register(SchedulTableHeaderView.self, forHeaderFooterViewReuseIdentifier: SchedulTableHeaderView.reuseIdentifier)
    }
    
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
        
        foucsCellObservable
            .delay(.milliseconds(350), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, foucsDate in
                guard let models = vc.dataSource?.sectionModels else { return }
                guard let headerIndex = models.firstIndex(where: { $0.dateComponents == foucsDate }) else { return }
                vc.systemIsDragging = true
                vc.tableView.scrollToRow(at: .init(row: 0, section: headerIndex), at: .middle, animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    
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

extension ScheduleTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 203
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SchedulTableHeaderView.reuseIdentifier) as? SchedulTableHeaderView else {
            return nil
        }
        
        let headerText = dataSource?[section].headerText
        header.tag = section
        header.setText(headerText)
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

extension ScheduleTableViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let viewHeight = self.view.frame.height
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let tabHeight = self.tabBarController?.tabBar.frame.height
        let maxY = offsetY + viewHeight
        
        if !systemIsDragging {
            
            // 구현해야 함
            if contentHeight < maxY {
                print("마지막 셀이야!!!")
            }
            
            guard let firstView = visibleHeaders.first else { return }
            notifyIfCrossedCenterLine(center: centerPoint(), view: firstView)
        }
    }
}

// MARK: - Helper
extension ScheduleTableViewController {
    private func centerPoint() -> CGFloat {
        let centerPoint = self.view.frame.height / 2
        let tabHeight = self.tabBarController?.tabBar.frame.height ?? 0
        return centerPoint - tabHeight
    }
    
    private func notifyIfCrossedCenterLine(center: CGFloat, view: UIView) {
        
        
        guard let viewFrame = view.superview?.convert(view.frame, to: self.view) else { return }
        
        if center > viewFrame.origin.y {
            guard let dataSource = dataSource else { return }
            let components = dataSource[view.tag].dateComponents
            dateObervable.onNext(components)
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13, *)
struct CalendarAndEventsViewController_Preview: PreviewProvider {
    static var previews: some View {
        CalendarAndEventsViewController(title: "일정관리", reactor: CalendarViewReactor(fetchUseCase: fetchRecentScheduleMock())).showPreview()
    }
}
#endif

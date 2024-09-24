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
    
    private let eventObservable: Observable<[ScheduleTableModel]>
    private var dataSource: RxTableViewSectionedReloadDataSource<ScheduleTableModel>?
    
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
    
    init(eventObservable: Observable<[ScheduleTableModel]>) {
        self.eventObservable = eventObservable
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
        
        eventObservable
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource!))
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
        header.setText(headerText)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
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

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

final class ScheduleTableViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    private let eventObservable: Observable<[Schedule]>
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .systemYellow
        table.showsVerticalScrollIndicator = false
        table.sectionHeaderHeight = 0
        table.contentInset = .init(top: 28, left: 0, bottom: 50, right: 0)
        table.clipsToBounds = true
        return table
    }()
    
    init(eventObservable: Observable<[Schedule]>) {
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
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        self.tableView.register(SchedulTableHeaderView.self, forHeaderFooterViewReuseIdentifier: SchedulTableHeaderView.reuseIdentifier)
    }
    
    private func setBinding() {
        eventObservable
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: ScheduleTableViewCell.reuseIdentifier, cellType: ScheduleTableViewCell.self)) { index, item, cell in
                
                cell.configure(viewModel: .init(schedule: item))
                cell.selectionStyle = .none
                
            }
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
        
        header.setText("2024년 9월 25일 일요일")
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
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

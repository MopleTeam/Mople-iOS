//
//  SearchTableViewController.swift
//  Mople
//
//  Created by CatSlave on 12/25/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class SearchResultViewController: BaseViewController, View {
    typealias Reactor = SearchPlaceReactor
    
    var disposeBag = DisposeBag()
    
    private var isSearchHistory = false
    private var historyCount: Int?
        
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.contentInset = .init(top: 0, left: 0, bottom: 10, right: 0)
        table.clipsToBounds = true
        return table
    }()
    
    init(reactor: SearchPlaceReactor?) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.Default.white
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(SearchPlaceTableCell.self, forCellReuseIdentifier: SearchPlaceTableCell.reuseIdentifier)
        self.tableView.register(SearchPlaceTableHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchPlaceTableHeaderView.reuseIdentifier)
    }
    
    func bind(reactor: SearchPlaceReactor) {
        
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        Observable.combineLatest(viewDidLayout, reactor.pulse(\.$searchResult))
            .map({ $0.1 })
            .compactMap({ $0 })
            .filter({ !$0.places.isEmpty })
            .do(onNext: { [weak self] result in
                self?.isSearchHistory = result.isCached
                self?.historyCount = result.places.count
            })
            .map({ $0.places })
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: SearchPlaceTableCell.reuseIdentifier, cellType: SearchPlaceTableCell.self)) { [weak self] index, item, cell in
                cell.configure(with: .init(placeInfo: item))
                cell.selectionStyle = .none
                cell.shouldShowButton(isEnabled: self?.isSearchHistory ?? false)
                cell.deleteButtonTapped = {
                    self?.reactor?.action.onNext(.deletePlace(index: index))
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map({ Reactor.Action.showDetailPlace(index: $0.row) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard self.isSearchHistory else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchPlaceTableHeaderView.reuseIdentifier) as! SearchPlaceTableHeaderView
        header.setCount(historyCount ?? 0)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.isSearchHistory ? 50 : 0
    }
}

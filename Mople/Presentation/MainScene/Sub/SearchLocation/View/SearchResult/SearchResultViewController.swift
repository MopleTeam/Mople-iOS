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

final class SearchResultViewController: BaseViewController, View, UIScrollViewDelegate {
    typealias Reactor = SearchPlaceViewReactor
    
    var disposeBag = DisposeBag()
    
    private var isSearchHistory = false
    
    private let countView: CountView = {
        let view = CountView(title: "최근 검색")
        view.frame.size.height = 50
        return view
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.clipsToBounds = true
        return table
    }()
    
    init(reactor: SearchPlaceViewReactor?) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(SearchPlaceTableCell.self, forCellReuseIdentifier: SearchPlaceTableCell.reuseIdentifier)
    }
    
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.Default.white
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bind(reactor: SearchPlaceViewReactor) {
        
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        let fetchResult = Observable.combineLatest(viewDidLayout, reactor.pulse(\.$searchResult))
            .compactMap({ $0.1 })
            .do { [weak self] result in
                self?.isSearchHistory = result.isCached
            }
            .map { $0.places }
            .share()
        
        fetchResult
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
        
        fetchResult
            .map({ $0.count })
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self, onNext: { [weak self] vc, count in
                self?.setCountView(count)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map({ Reactor.Action.selectedPlace(index: $0.row) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setCountView(_ count: Int) {
        if isSearchHistory {
            tableView.tableHeaderView = countView
            countView.countText = "\(count)개"
        } else {
            tableView.tableHeaderView = nil
        }
    }
}

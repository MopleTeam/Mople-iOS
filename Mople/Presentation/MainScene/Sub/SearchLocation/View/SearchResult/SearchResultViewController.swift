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
    
    // MARK: - Reactor
    typealias Reactor = SearchPlaceViewReactor
    private var searchPlaceReactor: SearchPlaceViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private var isSearchHistory = false
    
    // MARK: - UI Components
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
    
    // MARK: - LifeCycle
    init(reactor: SearchPlaceViewReactor?) {
        super.init()
        self.searchPlaceReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupTableView()
        setLayout()
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(SearchPlaceTableCell.self, forCellReuseIdentifier: SearchPlaceTableCell.reuseIdentifier)
    }
    
    private func setLayout() {
        self.view.backgroundColor = ColorStyle.Default.white
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setCountView(_ count: Int) {
        if isSearchHistory {
            tableView.tableHeaderView = countView
            countView.countText = "\(count)개"
        } else {
            tableView.tableHeaderView = nil
        }
    }
    
    // MARK: - Reactor Setup
    private func setReactor() {
        reactor = searchPlaceReactor
    }
    
    func bind(reactor: SearchPlaceViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        tableView.rx.itemSelected
            .map({ Reactor.Action.selectedPlace(index: $0.row) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        let fetchResult = reactor.pulse(\.$searchResult)
            .compactMap({ $0 })
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
        
        let viewDidLayOut = self.rx.viewDidLayoutSubviews
            .take(1)
        
        Observable.zip(viewDidLayOut, fetchResult)
            .map { $0.1 }
            .map({ $0.count })
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self, onNext: { [weak self] vc, count in
                self?.setCountView(count)
            })
            .disposed(by: disposeBag)
    }
}

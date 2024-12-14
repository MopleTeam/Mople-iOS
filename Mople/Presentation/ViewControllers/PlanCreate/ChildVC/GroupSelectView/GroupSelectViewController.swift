//
//  GroupSelectViewController.swift
//  Mople
//
//  Created by CatSlave on 12/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

final class GroupSelectViewController: UIViewController, View {
    
    typealias Reactor = PlanCreateViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Observer
    public var closeButtonTap: ControlEvent<Void> {
        return sheetView.closeButtonTap
    }
    
    public var completedButtonTap: ControlEvent<Void> {
        return sheetView.completedButtonTap
    }
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGray
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    private lazy var sheetView: DefaultBottomSheetView = {
        let view = DefaultBottomSheetView(contentView: tableView)
        view.setTitle("테스트")
        return view
    }()
    
    init(reactor: PlanCreateViewReactor) {
        print(#function, #line, "LifeCycle Test GroupList TableView Created" )
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test GroupList TableView Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setAction()
        setPresentationStyle()
    }
    
    // MARK: - ModalStyle
    private func setPresentationStyle() {
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [ .medium() ]
    }
    
    private func setupUI() {
        view.addSubview(sheetView)
        
        sheetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.register(GroupSelectTableCell.self, forCellReuseIdentifier: GroupSelectTableCell.reuseIdentifier)
    }
    
    func bind(reactor: PlanCreateViewReactor) {
        print(#function, #line, "Path : # 1214 ")
        
        Observable.combineLatest(self.rx.viewWillAppear, reactor.pulse(\.$testCount))
            .do(onNext: { test in
                print(#function, #line, "test : \(test)" )
                
            })
            .map({ $0.1 })
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: GroupSelectTableCell.reuseIdentifier, cellType: GroupSelectTableCell.self)) { index, item, cell in
      
            }
            .disposed(by: disposeBag)
    }
    
    private func setAction() {
        tableView.rx.itemSelected
            .subscribe(with: self, onNext: { vc, _ in

            })
            .disposed(by: disposeBag)
    }
}

extension GroupSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

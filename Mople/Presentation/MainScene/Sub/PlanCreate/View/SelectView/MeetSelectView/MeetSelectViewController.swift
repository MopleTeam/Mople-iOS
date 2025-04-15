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

final class MeetSelectViewController: BaseViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = CreatePlanViewReactor
    private var createPlanReactor: CreatePlanViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var sheetView: CustomSheetView = {
        let sheetView = CustomSheetView(contentView: tableView)
        sheetView.setTitle(TextStyle.CreatePlan.Picker.meet)
        return sheetView
    }()
    
    // MARK: - LifeCycle
    init(reactor: CreatePlanViewReactor?) {
        super.init()
        self.createPlanReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setPresentationStyle()
        setReactor()
    }
    
    // MARK: - ModalStyle
    private func setPresentationStyle() {
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [ .medium() ]
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setupTableView()
    }
    
    private func setLayout() {
        view.addSubview(sheetView)
        
        sheetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(MeetSelectTableCell.self, forCellReuseIdentifier: MeetSelectTableCell.reuseIdentifier)
    }
    
    // MARK: - Action
    private func setAction() {
        sheetView.rx.closeEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Setup
extension MeetSelectViewController {
    private func setReactor() {
        reactor = createPlanReactor
    }
    
    func bind(reactor: CreatePlanViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        tableView.rx.itemSelected
            .asDriver()
            .map { Reactor.Action.setValue(.meet($0.row)) }
            .drive(with: self, onNext: { vc, action  in
                reactor.action.onNext(action)
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        reactor.pulse(\.$meets)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: MeetSelectTableCell.reuseIdentifier, cellType: MeetSelectTableCell.self)) { index, item, cell in
      
                cell.configure(with: .init(meetSummary: item))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
    }
}

extension MeetSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


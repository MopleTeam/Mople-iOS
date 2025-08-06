//
//  MenstionListViewController.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class MentionListViewController: BaseViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = MentionListViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private let cellHeight: CGFloat = 60
    
    // MARK: - Observer
    private let fetchNextPage: PublishSubject<Void> = .init()
    
    // MARK: - Constraints
    private var height: Constraint?
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.tableHeaderView = .init(frame: .init(origin: .zero, size: .init(width: table.bounds.width,
                                                                              height: 0.1)))
        table.tableFooterView = .init(frame: .init(origin: .zero, size: .init(width: table.bounds.width,
                                                                              height: 0.1)))
        table.sectionFooterHeight = 0
        table.backgroundColor = .defaultRed
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.clipsToBounds = true
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()

    // MARK: - LifeCycle
    init(reactor: MentionListViewReactor) {
        super.init(screenName: nil)
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
    
    // MARK: - UI Setup
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(MentionListCell.self,
                                forCellReuseIdentifier: MentionListCell.reuseIdentifier)
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        self.view.backgroundColor = .systemMint
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Reactor Setup
extension MentionListViewController {
 
    func bind(reactor: Reactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
    }
    
    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        fetchNextPage
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.fetchNextPage }
            .compactMap({ $0 })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$members)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: MentionListCell.reuseIdentifier,
                                           cellType: MentionListCell.self)) ({ index, item, cell in
                cell.configure(memberInfo: item)
                cell.selectionStyle = .none
            }).disposed(by: disposeBag)
        
        reactor.pulse(\.$members)
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, list in
            })
            .disposed(by: disposeBag)
    }
    
    private func updateHeight(listCount: Int) {
        let maxHeight = cellHeight * 4
        let calculateHeight = cellHeight * CGFloat(listCount)
        let height = min(maxHeight, calculateHeight)
        self.height?.update(offset: height)
        self.view.layoutIfNeeded()
    }
}

extension MentionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = cell.frame.size.height
        print(#function, #line, "Path : # cell height \(height) ")
    }
}

final class MentionListCell: UITableViewCell {
    
    // MARK: - UI Components
    private let memberView: MemberView = {
        let view = MemberView()
        view.setFont(font: FontStyle.Body1.regular)
        view.backgroundColor = .systemPink
        return view
    }()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .systemMint
        self.contentView.addSubview(memberView)
        
        memberView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(12)
        }
    }

    public func configure(memberInfo: MemberInfo) {
        memberView.configure(memberInfo: memberInfo)
    }
}

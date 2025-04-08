//
//  MemberListViewController.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

final class MemberListViewController: TitleNaviViewController, View, UIScrollViewDelegate {
    
    typealias Reactor = MemberListViewReactor
    
    // MARK: - Observer
    private let endFlow: PublishSubject<Void> = .init()
    
    // MARK: - Varibables
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let countView: CountView = {
        let view = CountView(title: "참여자 목록")
        view.frame.size.height = 64
        view.setBottomInset(16)
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: ColorStyle.Gray._04)
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
    
    // MARK: - Life Cycle
    init(title: String,
         reactor: MemberListViewReactor) {
        super.init(title: title)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }
    
    // MARK: - UI Setup
    private func initalSetup() {
        setNaviItem()
        setupTableView()
        setupUI()
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(MemberListTableCell.self,
                                forCellReuseIdentifier: MemberListTableCell.reuseIdentifier)
    }
    
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.Default.white
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func bind(reactor: MemberListViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        naviBar.leftItemEvent
            .map { Reactor.Action.endView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        endFlow
            .map { Reactor.Action.endFlow }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$members)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: MemberListTableCell.reuseIdentifier,
                                           cellType: MemberListTableCell.self)) { index, item, cell in
                cell.configure(with: .init(memberInfo: item))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$members)
            .asDriver(onErrorJustReturn: [])
            .map({ $0.count })
            .drive(with: self, onNext: { vc, count in
                vc.countView.countText = "\(count)명"
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, err in
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 에러 핸들링
    private func handleError(_ err: MemberListError) {
        switch err {
        case let .noResponse(err):
            alertManager.showResponseErrorMessage(err: err,
                                                 completion: { [weak self] in
                self?.endFlow.onNext(())
            })
        case .unknown:
            alertManager.showDefatulErrorMessage()
        }
    }
}

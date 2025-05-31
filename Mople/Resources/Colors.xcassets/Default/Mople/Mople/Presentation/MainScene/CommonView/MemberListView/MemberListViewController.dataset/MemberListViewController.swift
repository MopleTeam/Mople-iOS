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
    
    // MARK: - Reactor
    typealias Reactor = MemberListViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Observer
    private let endFlow: PublishSubject<Void> = .init()
    private let userProfileTap: PublishSubject<String?> = .init()
    
    // MARK: - UI Components
    private let countView: CountView = {
        let view = CountView(title: L10n.memberList)
        view.frame.size.height = 64
        view.setBottomInset(16)
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: .gray04)
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
    init(screenName: ScreenName,
         title: String?,
         reactor: MemberListViewReactor) {
        super.init(screenName: screenName,
                   title: title)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setNaviItem()
        setupTableView()
        setLayout()
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    private func setupTableView() {
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(MemberListTableCell.self,
                                forCellReuseIdentifier: MemberListTableCell.reuseIdentifier)
    }
    
    private func setLayout() {
        self.view.backgroundColor = .defaultWhite
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
}

// MARK: - Reactor Setup
extension MemberListViewController {
 
    func bind(reactor: MemberListViewReactor) {
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
        naviBar.leftItemEvent
            .map { Reactor.Action.flow(.endView) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        endFlow
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        userProfileTap
            .map { Reactor.Action.flow(.showUserImage(imagePath: $0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$members)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: MemberListTableCell.reuseIdentifier,
                                           cellType: MemberListTableCell.self)) { [weak self] index, item, cell in
                cell.profileTapped = { [weak self] in
                    self?.userProfileTap.onNext(item.imagePath)
                }
                cell.configure(with: .init(memberInfo: item))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$members)
            .asDriver(onErrorJustReturn: [])
            .map({ $0.count })
            .drive(with: self, onNext: { vc, count in
                vc.countView.countText = L10n.peopleCount(count)
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

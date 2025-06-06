//
//  GroupViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class MeetListViewController: TitleNaviViewController, View, UIScrollViewDelegate {
    
    // MARK: - Reactor
    typealias Reactor = MeetListViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let joinMeet: PublishSubject<Meet> = .init()
    
    // MARK: - UI Components
    private let borderView: UIView = {
        let view = UIView()
        view.layer.makeLine(width: 1)
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.tableHeaderView = .init(frame: .init(origin: .zero,
                                                   size: .init(width: 0,
                                                               height: 28)))
        table.clipsToBounds = true
        return table
    }()
    
    private let emptyView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setTitle(text: L10n.Meetlist.empty)
        view.setImage(image: .emptyGroup)
        return view
    }()
    
    private let addMeetButton: BaseButton = {
        let btn = BaseButton()
        btn.setImage(image: .addButton)
        btn.setRadius(27)
        btn.layer.zPosition = 1
        btn.layer.makeShadow(opactity: 0.02,
                             radius: 24,
                             offset: .init(width: 0, height: 0))
        return btn
    }()
    
    // MARK: - Refresh Control
    private let refreshControl = UIRefreshControl()
        
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         reactor: MeetListViewReactor) {
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
        setLayout()
        setupTableView()
    }

    private func setLayout() {
        self.view.backgroundColor = .bgPrimary
        self.view.addSubview(borderView)
        self.view.addSubview(tableView)
        self.view.addSubview(emptyView)
        self.view.addSubview(addMeetButton)
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        addMeetButton.snp.makeConstraints { make in
            make.size.equalTo(54)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(24)
        }
    }
    
    private func setupTableView() {
        tableView.refreshControl = refreshControl
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(MeetListTableCell.self, forCellReuseIdentifier: MeetListTableCell.reuseIdentifier)
    }
}

// MARK: - Reactor Setup
extension MeetListViewController {

    func bind(reactor: MeetListViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
        setNotificationBind(reactor)
    }

    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        tableView.rx.itemSelected
            .map({ Reactor.Action.flow(.selectMeet(index: $0.row)) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        joinMeet
            .map({ Reactor.Action.flow(.showJoinMeet($0)) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addMeetButton.rx.tap
            .map { Reactor.Action.flow(.createMeet) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setNotificationBind(_ reactor: Reactor) {
        NotificationManager.shared.addMeetObservable()
            .map { Reactor.Action.updateMeet($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addPlanObservable()
            .map { _ in Reactor.Action.fetchMeetList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$meetList)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, groupList in
                vc.emptyView.isHidden = !groupList.isEmpty
                vc.tableView.isHidden = groupList.isEmpty
            })
            .disposed(by: disposeBag)

        reactor.pulse(\.$meetList)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: MeetListTableCell.reuseIdentifier, cellType: MeetListTableCell.self)) { index, item, cell in
                cell.configure(with: .init(meet: item))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isRefreshed)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: ())
            .map({ false })
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, err in
                vc.alertManager.showDefatulErrorMessage()
            })
            .disposed(by: disposeBag)
    }
}

extension MeetListViewController {
    public func presentJoinMeet(with meet: Meet) {
        joinMeet.onNext(meet)
    }
}

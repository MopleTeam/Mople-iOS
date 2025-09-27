//
//  NotifyListViewController.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

final class NotifyListViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = NotifyListViewReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Transition
    var dismissTransition: AppTransition = .init(type: .dismiss)
    
    // MARK: - Observable
    private let nextPage: PublishSubject<Void> = .init()
    
    // MARK: - UI Components
    private let countView: CountView = {
        let view = CountView(title: L10n.Notifylist.new)
        view.setFont(font: FontStyle.Body1.medium,
                     textColor: .gray04)
        view.setMargin(inset: .init(top: 28, left: 20, bottom: 16, right: 20))
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    private let emptyNotifyView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setTitle(text: L10n.Notifylist.empty)
        view.setImage(image: .emptyNotify)
        return view
    }()
    
    // MARK: - Refresh Control
    private let refreshControl = UIRefreshControl()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         reactor: NotifyListViewReactor) {
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
        setEdgeGesture()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavi()
        setLayout()
        setupTableView()
    }
    
    private func setLayout() {
        self.view.addSubview(countView)
        self.view.addSubview(emptyNotifyView)
        self.view.addSubview(tableView)
        
        self.countView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.emptyNotifyView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(countView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setupNavi() {
        self.setBarItem(type: .left)
    }
    
    private func setupTableView() {
        tableView.refreshControl = refreshControl
        tableView.rx.delegate.setForwardToDelegate(self, retainDelegate: false)
        self.tableView.register(NotifyTableCell.self, forCellReuseIdentifier: NotifyTableCell.reuseIdentifier)
    }
    
    private func setCount(_ count: Int) {
        countView.countText = L10n.itemCount(count)
    }
    
    private func setFooterView(with page: PageInfo) {
        if page.hasNext {
            tableView.tableFooterView = .init(frame: .init(origin: .zero, size: .init(width: 0, height: 0.1)))
        } else {
            let label = UILabel(frame: .init(origin: .zero, size: .init(width: tableView.frame.width,
                                                                        height: 68)))
            #warning("언어 지원 필요")
            label.text = "최근 30일 이내 알림 내역만 확인할 수 있어요"
            label.font = FontStyle.Body1.regular
            label.textColor = .gray04
            label.textAlignment = .center
            tableView.tableFooterView = label
        }
    }
    
    // MARK: - Gesture
    private func setEdgeGesture() {
        guard let currentNavi = self.findCurrentNavigation(),
              let appNavi = currentNavi as? AppNaviViewController else { return }
        tableView.panGestureRecognizer.require(toFail: appNavi.edgeGesture)
    }
}

// MARK: - Reactor Setup
extension NotifyListViewController {

    func bind(reactor: NotifyListViewReactor) {
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
        tableView.rx.itemSelected
            .map { Reactor.Action.flow(.selectNotify(index: $0.row)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextPage
            .throttle(.seconds(1),
                      latest: false,
                      scheduler: MainScheduler.instance)
            .map { Reactor.Action.fetchNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.naviBar.leftItemEvent
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$notifyList)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(
                cellIdentifier: NotifyTableCell.reuseIdentifier,
                cellType: NotifyTableCell.self)
            ) { index, item, cell in
                cell.configure(viewModel: .init(notify: item))
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$notifyList)
            .asDriver(onErrorJustReturn: [])
            .map {
                $0.filter { !$0.isRead }.count
            }
            .drive(with: self, onNext: { vc, newCount in
                vc.setCount(newCount)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$notifyList)
            .asDriver(onErrorJustReturn: [])
            .map { !$0.isEmpty }
            .drive(with: self, onNext: { vc, hasNotify in
                vc.tableView.isHidden = !hasNotify
                vc.emptyNotifyView.isHidden = hasNotify
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isRefreshed)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: ())
            .map({ false })
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$pageInfo)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, page in
                vc.setFooterView(with: page)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, _ in
                vc.alertManager.showDefatulErrorMessage()
            })
            .disposed(by: disposeBag)
    }
}

extension NotifyListViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isBottom(threshold: 50),
              reactor?.currentState.pageInfo?.hasNext == true else { return }
        nextPage.onNext(())
    }
}

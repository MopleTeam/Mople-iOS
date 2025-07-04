//
//  MemberListViewController.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

final class MemberListViewController: TitleNaviViewController, View, UIScrollViewDelegate {
    
    // MARK: - Reactor
    typealias Reactor = MemberListViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private let viewType: MemberListType
    private let sectionHeight: CGFloat = 60
    
    // MARK: - Observer
    private let endFlow: PublishSubject<Void> = .init()
    private let userProfileTap: PublishSubject<String?> = .init()
    private let invite: PublishSubject<Void> = .init()
    
    // MARK: - DataSource
    private var dataSource: RxTableViewSectionedReloadDataSource<MembersSectionModel>?
    
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
        let table = UITableView(frame: .zero, style: .grouped)
        table.sectionHeaderTopPadding = 0
        table.backgroundColor = .defaultWhite
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.clipsToBounds = true
        return table
    }()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         reactor: MemberListViewReactor,
         type: MemberListType) {
        viewType = type
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
        setupDataSource()
        setEdgeGesture()
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
        tableView.register(MemberTableHeader.self, forHeaderFooterViewReuseIdentifier: MemberTableHeader.reuseIdentifier)
    }
    
    private func setLayout() {
        self.view.backgroundColor = .defaultWhite
        view.addSubview(countView)
        view.addSubview(tableView)
        
        countView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom).offset(28)
            make.horizontalEdges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(countView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
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
        userProfileTap
            .map { Reactor.Action.flow(.showUserImage(imagePath: $0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        invite
            .map { Reactor.Action.invite }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        naviBar.leftItemEvent
            .map { Reactor.Action.flow(.endView) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        endFlow
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$inviteUrl)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { [weak self] url -> String? in
                guard let self,
                      let url else { return nil }
                return makeInviteMessage(with: url)
            }
            .drive(with: self, onNext: { vc, url in
                vc.showActivityViewController(items: [url])
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$members)
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$members)
            .asDriver(onErrorJustReturn: [])
            .map({ $0.reduce(0, { $0 + $1.items.count}) })
            .drive(with: self, onNext: { vc, count in
                vc.countView.countText = L10n.peopleCount(count)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, err in
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupDataSource() {
        
        dataSource = RxTableViewSectionedReloadDataSource<MembersSectionModel>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                guard let self else { return UITableViewCell() }
                let cell = tableView.dequeueReusableCell(withIdentifier: MemberListTableCell.reuseIdentifier) as! MemberListTableCell
                cell.profileTapped = { [weak self] in
                    self?.userProfileTap.onNext(item.imagePath)
                }
                cell.configure(with: .init(memberInfo: item))
                cell.selectionStyle = .none
                return cell
            }
        )
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

extension MemberListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard case .meet = viewType else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: MemberTableHeader.reuseIdentifier) as! MemberTableHeader
        
        header.rx.tapped
            .bind(to: invite)
            .disposed(by: disposeBag)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard case .meet = viewType else { return 0 }
        return sectionHeight
    }
}

// MARK: - Invite
extension MemberListViewController {
    private func makeInviteMessage(with url: String) -> String {
        let inviteComment = L10n.Meetdetail.inviteMessage
        return inviteComment + "\n" + url
    }
    
    private func showActivityViewController(items: [Any]) {
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true)
    }
}

//
//  HomeViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import ReactorKit
import Kingfisher
import RxSwift
import RxCocoa

final class HomeViewController: DefaultViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = HomeViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    // Header
    private let logoView: UIImageView = {
        let view = UIImageView()
        view.image = .logo
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let topEmptyView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .horizontal)
        return view
    }()
    
    private let notifyButton = UIButton()
    
    private lazy var topStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [logoView, topEmptyView, notifyButton])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        sv.clipsToBounds = false
        return sv
    }()
    
    // Content
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.refreshControl = .init()
        return view
    }()
    
    private let contentView = UIView()
    
    private(set) var recentPlanContainerView = UIView()
    
    private let makeMeetButton: CardButton = {
        let btn = CardButton()
        btn.setTitle(text: L10n.Home.createMeet)
        btn.setImage(image: .makeGroup)
        return btn
    }()
    
    private let makePlanButton: CardButton = {
        let btn = CardButton()
        btn.setTitle(text: L10n.Home.createPlan)
        btn.setImage(image: .makeSchedule)
        return btn
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [makeMeetButton, makePlanButton])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 8, right: 20)
        return sv
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .vertical)
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [recentPlanContainerView,
                                                buttonStackView,
                                                spacerView])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    // MARK: - Refresh Control
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Child VC
    private let recentPlanVC: RecentPlanViewController
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         reactor: HomeViewReactor,
         recentPlanVC: RecentPlanViewController) {
        self.recentPlanVC = recentPlanVC
        super.init(screenName: screenName)
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
        setChildVC()
        setScrollView()
    }
    
    private func setLayout() {
        self.view.backgroundColor = .bgPrimary
        self.view.addSubview(topStackView)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(mainStackView)
        
        topStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topStackView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        logoView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(40)
        }
        
        notifyButton.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(40)
        }
        
        recentPlanContainerView.snp.makeConstraints { make in
            make.height.equalTo(270)
        }
    }
    
    private func setScrollView() {
        scrollView.refreshControl = refreshControl
    }
    
    private func setChildVC() {
        self.add(child: recentPlanVC,
                 container: recentPlanContainerView)
    }
    
    private func setNotifyButton(hasNotify: Bool) {
        let image: UIImage = hasNotify ? .bellOn : .bellOff
        notifyButton.setImage(image, for: .normal)
    }
}

// MARK: - Reactor Setup
extension HomeViewController {
    func bind(reactor: HomeViewReactor) {
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
                vc.setReactorStateBind(reactor: reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        makeMeetButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.createGroup) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        makePlanButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.createPlan) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        notifyButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.notify) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setNotificationBind(_ reactor: Reactor) {
        NotificationManager.shared.addPlanObservable()
            .map { Reactor.Action.updatePlan($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addParticipatingObservable()
            .map { Reactor.Action.updatePlan($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addMeetObservable()
            .map { Reactor.Action.updateMeet($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addObservable(name: .midnightUpdate)
            .map { Reactor.Action.reloadDay }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addObservable(name: .changedNotifyCount)
            .map { Reactor.Action.fetchNotifyStatus }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(reactor: Reactor) {
        reactor.pulse(\.$hasNotify)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, hasNotify in
                vc.setNotifyButton(hasNotify: hasNotify)
            })
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
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Error Handling
    private func handleError(_ err: HomeError) {
        switch err {
        case .emptyMeet:
            self.showEmptyMeetAlert()
        case let .midnight(err):
            alertManager.showDateErrorMessage(err: err)
        case .unknown:
            alertManager.showDefatulErrorMessage()
        }
    }
}

extension HomeViewController {
    private func showEmptyMeetAlert() {
        let createAction: DefaultAlertAction = .init(text: L10n.createMeet,
                                                     completion: { [weak self] in
            self?.reactor?.action.onNext(.flow(.createGroup))
        })
        
        alertManager.showDefaultAlert(title: L10n.Home.emptyMeetInfo,
                                      subTitle: L10n.Home.emptyMeetSubinfo,
                                      defaultAction: .init(text: L10n.cancle,
                                                           textColor: .gray01,
                                                           bgColor: .appTertiary),
                                      addAction: [createAction])
    }
}

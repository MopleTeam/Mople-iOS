//
//  HomeViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import ReactorKit
import Kingfisher

final class HomeViewController: DefaultViewController, View {
 
    // MARK: - Reactor
    typealias Reactor = HomeViewReactor
    private(set) var homeReactor: HomeViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = TextStyle.App.title
        label.font = FontStyle.Title.black
        label.textColor = ColorStyle.App.primary
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let notifyButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.bell, for: .normal)
        return btn
    }()
    
    private lazy var topStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, notifyButton])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        return sv
    }()
    
    private(set) var recentPlanContainerView = UIView()
            
    private let makeMeetButton: CardButton = {
        let btn = CardButton()
        btn.setTitle(text: TextStyle.Home.createGroup)
        btn.setImage(image: .makeGroup)
        return btn
    }()
    
    private let makeScheduleButton: CardButton = {
        let btn = CardButton()
        btn.setTitle(text: TextStyle.Home.createSchedule)
        btn.setImage(image: .makeSchedule)
        return btn
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [makeMeetButton, makeScheduleButton])
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
        let sv = UIStackView(arrangedSubviews: [topStackView,
                                                recentPlanContainerView,
                                                buttonStackView,
                                                spacerView])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    // MARK: - LifeCycle
    init(reactor: HomeViewReactor) {
        super.init()
        self.homeReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        super.viewDidLoad()
        setupUI()
        setReactor()
        checkBadgeCount()
    }
    
    private func checkBadgeCount() {
        let badgeCount = UIApplication.shared.applicationIconBadgeNumber
        print(#function, #line, "badgeCount : \(badgeCount)" )
        UIApplication.shared.applicationIconBadgeNumber = 40
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.BG.primary
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(mainStackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        recentPlanContainerView.snp.makeConstraints { make in
            make.height.equalTo(270)
        }
        
        notifyButton.snp.makeConstraints { make in
            make.width.height.greaterThanOrEqualTo(40)
        }
    }
}

// MARK: - Reactor Setup
extension HomeViewController {
    private func setReactor() {
        reactor = homeReactor
    }
    
    func bind(reactor: HomeViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
        setNotification(reactor: reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        rx.viewDidAppear
            .map { Reactor.Action.checkNotificationPermission }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        makeMeetButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.createGroup) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        makeScheduleButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.createPlan) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        notifyButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.notify) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
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
    
    private func setNotification(reactor: Reactor) {
        EventService.shared.addPlanObservable()
            .map { Reactor.Action.updatePlan($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        EventService.shared.addParticipatingObservable()
            .map { Reactor.Action.updatePlan($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        EventService.shared.addMeetObservable()
            .map { Reactor.Action.updateMeet($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        EventService.shared.addObservable(name: .midnightUpdate)
            .map { Reactor.Action.reloadDay }
            .bind(to: reactor.action)
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
        let createAction: DefaultAlertAction = .init(text: "모임 생성하기",
                                          completion: { [weak self] in
            self?.reactor?.action.onNext(.flow(.createGroup))
        })
    
        alertManager.showAlert(title: "아직 소속된 모임이 없어요",
                               subTitle: "먼저 모임을 가입또는 생성해서 일정을 추가해보세요!",
                               defaultAction: .init(text: "취소",
                                                    textColor: ColorStyle.Gray._01,
                                                    bgColor: ColorStyle.App.tertiary),
                               addAction: [createAction])
    }
}



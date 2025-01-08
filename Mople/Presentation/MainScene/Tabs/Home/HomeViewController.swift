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
 
    typealias Reactor = HomeViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Manager
    private let alertManager = AlertManager.shared
    
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
    
    private let recentPlanContainerView = UIView()
    
    private lazy var resentPlanCollectionView = HomePlanCollectionViewController(reactor: reactor!)
    
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
    
    
    init(reactor: HomeViewReactor) {
        print(#function, #line, "LifeCycle Test HomeView Created" )
        super.init()
        self.reactor = reactor
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test HomeView Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(#function, #line)
        super.viewDidLoad()
        setupUI()
        addScheduleListCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function, #line)
    }
    
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
    
    private func addScheduleListCollectionView() {
        add(child: resentPlanCollectionView, container: recentPlanContainerView)
    }
    
    func bind(reactor: HomeViewReactor) {
        rx.viewDidLoad
            .map { _ in Reactor.Action.checkNotificationPermission }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.makeMeetButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.createGroup }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.makeScheduleButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.createPlan }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
}



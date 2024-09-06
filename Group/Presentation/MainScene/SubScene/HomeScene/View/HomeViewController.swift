//
//  HomeViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import ReactorKit
import Kingfisher

final class HomeViewController: UIViewController, View {
 
    typealias Reactor = ScheduleViewReactor
    
    var disposeBag = DisposeBag()
    
    private let titleLabel: DefaultLabel = {
        let label = DefaultLabel(itemConfigure: AppDesign.Home.title)
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let notifyButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "Bell"), for: .normal)
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
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
    
    private let containerView = UIView()
    
    private lazy var scheduleListCollectionView = ScheduleListCollectionViewController(reactor: reactor!)
    
    private let emptyDataView: UILabel = {
        let label = UILabel()
        label.text = "빈 화면"
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.backgroundColor = AppDesign.defaultWihte
        return label
    }()
    
    private let makeGroupButton: HomeButton = {
        let btn = HomeButton(backColor: AppDesign.defaultWihte,
                             radius: 12,
                             itemConfigure: AppDesign.Home.makeGroup)
        
        return btn
    }()
    
    private let makeScheduleButton: HomeButton = {
        let btn = HomeButton(backColor: AppDesign.defaultWihte,
                             radius: 12,
                             itemConfigure: AppDesign.Home.makeSchedule)
        
        return btn
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [makeGroupButton, makeScheduleButton])
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
    
    private lazy var allStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [topStackView,
                                                containerView,
                                                buttonStackView,
                                                spacerView])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(reactor: ScheduleViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        addScheduleListCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.view.backgroundColor = AppDesign.Home.BackColor
        
        self.view.addSubview(allStackView)
        self.containerView.addSubview(emptyDataView)
        
        allStackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints { make in
            make.height.equalTo(285)
        }
        
        notifyButton.snp.makeConstraints { make in
            make.width.height.greaterThanOrEqualTo(40)
        }
        
        emptyDataView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func addScheduleListCollectionView() {
        addChild(scheduleListCollectionView)
        containerView.addSubview(scheduleListCollectionView.view)
        scheduleListCollectionView.didMove(toParent: self)
        scheduleListCollectionView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bind(reactor: ScheduleViewReactor) {
        self.makeScheduleButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.logOutTest }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$schedules)
                .asDriver(onErrorJustReturn: [])
                .drive(onNext: { [weak self] schedules in
                    guard let self = self else { return }
                    if schedules.isEmpty {
                        self.emptyDataView.isHidden = false
                        self.scheduleListCollectionView.view.isHidden = true
                    } else {
                        self.emptyDataView.isHidden = true
                        self.scheduleListCollectionView.view.isHidden = false
                    }
                })
                .disposed(by: disposeBag)
    }
}



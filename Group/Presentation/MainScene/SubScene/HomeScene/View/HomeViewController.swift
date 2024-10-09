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
    
    private let titleLabel: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.Home.title)
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let notifyButton: UIButton = {
        let btn = UIButton()
        btn.setImage(AppDesign.Home.notifyImage, for: .normal)
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
    
    private let collectionContainerView = UIView()
    
    private lazy var scheduleListCollectionView = ScheduleListCollectionViewController(reactor: reactor!)
    
    #warning("configure")
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
                                                collectionContainerView,
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
        addScheduleListCollectionView()
    }
    
    init(reactor: ScheduleViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function, #line)
    }
    
    private func setupUI() {
        self.view.backgroundColor = AppDesign.mainBackColor
        
        self.view.addSubview(allStackView)
        self.collectionContainerView.addSubview(emptyDataView)
        
        allStackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        collectionContainerView.snp.makeConstraints { make in
            make.height.equalTo(270)
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
        collectionContainerView.addSubview(scheduleListCollectionView.view)
        scheduleListCollectionView.didMove(toParent: self)
        scheduleListCollectionView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setAction() {
        self.notifyButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
//                vc.scheduleListCollectionView.collectionView.scrollRectToVisible(.init(x: 1000, y: 0, width: 0, height: 0), animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: ScheduleViewReactor) {
        self.makeScheduleButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.logOutTest }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$schedules)
                .asDriver(onErrorJustReturn: [])
                .drive(with: self, onNext: { vc, schedules in
                    vc.emptyDataView.isHidden = !schedules.isEmpty
                    vc.collectionContainerView.isHidden = schedules.isEmpty
                })
                .disposed(by: disposeBag)
    }
}



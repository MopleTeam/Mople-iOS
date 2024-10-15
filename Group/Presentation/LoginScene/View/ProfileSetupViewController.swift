//
//  ProfileSetupViewController.swift
//  Group
//
//  Created by CatSlave on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import PhotosUI

class ProfileSetupViewController: UIViewController, View {
    typealias Reactor = ProfileSetupViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let mainTitle: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.Profile.main)
        label.numberOfLines = 2
        return label
    }()
    
    private let profileContainerView = UIView()
    
    private lazy var profileSetupView: BaseProfileViewController = {
        let viewController = BaseProfileViewController(reactor: reactor!)
        return viewController
    }()
    
    // MARK: - Indicator
    private let indicator = BaseLoadingOverlay()
    
    // MARK: - LifeCycle
    init(reactor: ProfileSetupViewReactor) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print("ViewDidLoad 시점")
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
        addProfileSetupView()
    }

    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(mainTitle)
        self.view.addSubview(profileContainerView)
        self.view.addSubview(indicator)

        mainTitle.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(28)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        profileContainerView.snp.makeConstraints { make in
            make.top.equalTo(mainTitle.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(mainTitle.snp.horizontalEdges)
            make.bottom.equalToSuperview().inset(28)
        }

        indicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addProfileSetupView() {
        addChild(profileSetupView)
        profileContainerView.addSubview(profileSetupView.view)
        profileSetupView.didMove(toParent: self)
        profileSetupView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Binding
    func bind(reactor: ProfileSetupViewReactor) {
        
        rx.viewWillAppear
            .map { _ in Reactor.Action.getRandomNickname }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isLoad in
                vc.animatingIndicator(isLoad)
            })
            .disposed(by: disposeBag)
    }
}

extension ProfileSetupViewController {
    private func animatingIndicator(_ isLoad: Bool) {
        indicator.animating(isLoad)
    }
}



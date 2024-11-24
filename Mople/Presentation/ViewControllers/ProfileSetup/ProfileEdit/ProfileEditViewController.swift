//
//  ProfileEditViewController.swift
//  Group
//
//  Created by CatSlave on 10/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import PhotosUI

class ProfileEditViewController: DefaultViewController, View {
    typealias Reactor = ProfileFormViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    let previousProfile: ProfileInfo
        
    // MARK: - UI Components
    private let profileContainerView = UIView()
    
    private lazy var profileSetupView: ProfileSetupViewController = {
        let viewController = ProfileSetupViewController(type: .edit(previousProfile),
                                                        reactor: reactor!)
        return viewController
    }()

    // MARK: - LifeCycle
    init(profile: ProfileInfo,
         reactor: ProfileFormViewReactor) {
        self.previousProfile = profile
        defer { self.reactor = reactor }
        super.init(title: TextStyle.ProfileEdit.title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAction()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
        addProfileSetupView()
        setNaviItem()
    }

    private func setupLayout() {
        self.view.addSubview(profileContainerView)

        profileContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func addProfileSetupView() {
        addChild(profileSetupView)
        profileContainerView.addSubview(profileSetupView.view)
        profileSetupView.didMove(toParent: self)
        profileSetupView.view.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left, image: .arrowBack)
    }

    // MARK: - Binding
    func bind(reactor: ProfileFormViewReactor) {
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
    
    private func setupAction() {
        leftItemEvent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

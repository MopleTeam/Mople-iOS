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

class ProfileEditViewController: BaseViewController, View {
    typealias Reactor = ProfileSetupViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    let previousProfile: ProfileBuilder
    
    // MARK: - Observer
    private lazy var leftButtonObserver = addLeftButton(setImage: .arrowBack)
    
    // MARK: - UI Components
    private let profileContainerView = UIView()
    
    private lazy var profileSetupView: BaseProfileViewController = {
        let viewController = BaseProfileViewController(type: .edit,
                                                       reactor: reactor!)
        return viewController
    }()

    // MARK: - LifeCycle
    init(profile: ProfileBuilder,
         reactor: ProfileSetupViewReactor) {
        self.previousProfile = profile
        defer { self.reactor = reactor }
        super.init(title: "프로필 수정")
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
        setupLayout()
        addProfileSetupView()
        setProfile()
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

    private func setProfile() {
        profileSetupView.setEditProfile(previousProfile)
    }
    
    // MARK: - Binding
    func bind(reactor: ProfileSetupViewReactor) {
        leftButtonObserver
            .subscribe(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$setupCompleted)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

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
    
    // MARK: - Observer
    private lazy var leftButtonObserver = addLeftButton(setImage: .arrowBack)
    
    // MARK: - UI Components
    private let profileContainerView = UIView()
    
    private lazy var profileSetupView: BaseProfileViewController = {
        let viewController = BaseProfileViewController(reactor: reactor!)
        return viewController
    }()

    // MARK: - LifeCycle
    init(profile: Profile,
         title: String?,
         reactor: ProfileSetupViewReactor) {
        defer {
            self.reactor = reactor
            self.setProfile(profile)
        }
        super.init(title: title)
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
        setNavi()
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
    
    private func setNavi() {
        self.leftButtonObserver = addLeftButton(setImage: .arrowBack)
    }
    
    private func setProfile(_ profile: Profile) {
        profileSetupView.setProfile(profile)
    }
    
    // MARK: - Binding
    func bind(reactor: ProfileSetupViewReactor) {
        leftButtonObserver
            .subscribe(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

//
//  ProfileViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import RxSwift
import ReactorKit

struct ProfileUpdateModel {
    var currentProfile: ProfileBuilder
    var completedAction: ProfileSetupAction
}

final class ProfileViewController: BaseViewController, View {
    typealias Reactor = ProfileViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Observer
    private let fetchObserver: PublishSubject<Void> = .init()
    
    // MARK: - UI Components
    private let imageContainer = UIView()
        
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = .default
        return imageView
    }()
    
    private let profileNameButton: IconLabelButton = {
        let button = IconLabelButton(configure: AppDesign.ProfileManagement.edit,
                                     iconSize: 20,
                                     labelAligment: .fill)
        return button
    }()

    private let notifyLabel = IconLabelButton(configure: AppDesign.ProfileManagement.notify,
                                              labelAligment: .fill)
    
    private let personalLabel = IconLabelButton(configure: AppDesign.ProfileManagement.presonalInfo,
                                                labelAligment: .fill)
        
    
    private let versionTitleLabel = BaseLabel(configure: AppDesign.ProfileManagement.versionInfo)
    
    private let versionLabel: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.ProfileManagement.version)
        label.backgroundColor = AppDesign.defaultWihte
        label.text = Bundle.main.releaseVersionNumber
        return label
    }()
    
    private let logoutLabel = BaseLabel(configure: AppDesign.ProfileManagement.logout)
    
    private let resignLabel = BaseLabel(configure: AppDesign.ProfileManagement.resign)
    
    private lazy var profileStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainer, profileNameButton])
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .center
        sv.distribution = .fill
        sv.backgroundColor = AppDesign.defaultWihte
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 40, left: 20, bottom: 40, right: 20)
        return sv
    }()

    private lazy var menuStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [notifyLabel, personalLabel, versionTitleLabel])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 8, left: 20, bottom: 8, right: 20)
        sv.backgroundColor = AppDesign.defaultWihte
        return sv
    }()
    
    private lazy var accountManageStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [logoutLabel, resignLabel])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 8, left: 20, bottom: 8, right: 20)
        sv.backgroundColor = AppDesign.defaultWihte
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [profileStackView,
                                                menuStackView,
                                                accountManageStackView])
        sv.axis = .vertical
        sv.spacing  = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = AppDesign.ProfileManagement.borderColor
        return sv
    }()
    
    // MARK: - LifeCycle
    init(reactor: ProfileViewReactor) {
        defer { self.reactor = reactor }
        super.init(title: "마이페이지")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    // MARK: - UI Setup
    
    private func setupLayout() {
        print(#function, #line)
        self.view.addSubview(mainStackView)
        self.imageContainer.addSubview(profileImageView)
        self.versionTitleLabel.addSubview(versionLabel)
                
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        imageContainer.snp.makeConstraints { make in
            make.size.greaterThanOrEqualTo(profileImageView.snp.size)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        profileImageView.layer.cornerRadius = 40
        
        versionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        [notifyLabel, personalLabel, versionTitleLabel, logoutLabel, resignLabel].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
    }
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        fetchObserver
            .map { _ in Reactor.Action.fetchProfile }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        profileNameButton.rx.controlEvent(.touchUpInside)
            .compactMap { [weak self] () -> ProfileUpdateModel? in
                guard let self = self else { return nil }
                return makeUpdateModel()
            }
            .map { Reactor.Action.editProfile(updatedModel: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$userProfile)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, profile in
                vc.setProfile(profile)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 프로필 빌더 생성 및 적용
extension ProfileViewController {
    private func makeProfile() -> ProfileBuilder {
        let image = self.profileImageView.image
        let nickName = profileNameButton.text
        
        return .init(name: nickName, image: image)
    }
    
    private func setProfile(_ profile: ProfileInfo) {
        profileNameButton.setText(profile.name)
        _ = profileImageView.kfSetimage(profile.imagePath)
    }
}

extension ProfileViewController {
    
    
    /// 프로필 편집 뷰로 현재 프로필과 편집 완료 액션 전달
    private func makeUpdateModel() -> ProfileUpdateModel {
        return ProfileUpdateModel(currentProfile: makeProfile(),
                                  completedAction: .init(completed: reloadProfile))
    }
    
    /// 편집 완료 시 프로필 뷰의 프로필을 리롣,
    private func reloadProfile() {
        fetchObserver.onNext(())
    }
}


//
//  ProfileViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import RxSwift
import ReactorKit

final class ProfileViewController: TitleNaviViewController, View {
    typealias Reactor = ProfileViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let imageContainer = UIView()
        
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = .defaultIProfile
        return imageView
    }()
    
    private let profileNameButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(font: FontStyle.Title3.semiBold,
                     normalColor: ColorStyle.Gray._01)
        btn.setImage(image: .editPan)
        return btn
    }()

    private let notifyButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.Profile.notifyTitle,
                     font: FontStyle.Title3.medium,
                     normalColor: ColorStyle.Gray._01)
        btn.setImage(image: .listArrow)
        btn.setButtonAlignment(.fill)
        btn.setLayoutMargins(inset: .zero)
        return btn
    }()
    
    private let policyButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.Profile.policyTitle,
                     font: FontStyle.Title3.medium,
                     normalColor: ColorStyle.Gray._01)
        btn.setImage(image: .listArrow)
        btn.setButtonAlignment(.fill)
        btn.setLayoutMargins(inset: .zero)
        return btn
    }()
        
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = TextStyle.Profile.versionTitle
        label.font = FontStyle.Title3.medium
        label.textColor = ColorStyle.Gray._01
        return label
    }()
    
    private let versionInfoLabel: UILabel = {
        let label = UILabel()
        label.text = TextStyle.Profile.version
        label.font = FontStyle.Title3.medium
        label.textColor = ColorStyle.Gray._06
        return label
    }()
    
    private let logoutButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.Profile.logoutTitle,
                     font: FontStyle.Title3.medium,
                     normalColor: ColorStyle.Gray._01)
        btn.setButtonAlignment(.left)
        btn.setLayoutMargins(inset: .zero)
        return btn
    }()

    private let resignButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.Profile.resignTitle,
                     font: FontStyle.Title3.medium,
                     normalColor: ColorStyle.Gray._01)
        btn.setButtonAlignment(.left)
        btn.setLayoutMargins(inset: .zero)
        return btn
    }()
    
    private lazy var profileStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainer, profileNameButton])
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .center
        sv.distribution = .fill
        sv.backgroundColor = ColorStyle.Default.white
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 40, left: 20, bottom: 40, right: 20)
        return sv
    }()

    private lazy var menuStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [notifyButton, policyButton, versionLabel])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 8, left: 20, bottom: 8, right: 20)
        sv.backgroundColor = ColorStyle.Default.white
        return sv
    }()
    
    private lazy var accountManageStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [logoutButton, resignButton])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 8, left: 20, bottom: 8, right: 20)
        sv.backgroundColor = ColorStyle.Default.white
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
        sv.backgroundColor = ColorStyle.BG.secondary
        return sv
    }()
    
    // MARK: - LifeCycle
    init(title: String,
         reactor: ProfileViewReactor) {
        super.init(title: title)
        self.reactor = reactor
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
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(mainStackView)
        self.imageContainer.addSubview(profileImageView)
        self.versionLabel.addSubview(versionInfoLabel)
                
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
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
        
        versionInfoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        [notifyButton, policyButton, versionLabel, logoutButton, resignButton].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
    }
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        notifyButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.presentNotifyView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        policyButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.presentPolicyView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        logoutButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.logout }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        profileNameButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.editProfile }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        Observable.combineLatest(viewDidLayout, reactor.pulse(\.$userProfile))
            .map { $0.1 }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, profile in
                vc.setProfile(profile)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 프로필 적용
extension ProfileViewController {
    private func setProfile(_ profile: UserInfo) {
        profileNameButton.title = profile.name
        profileImageView.kfSetimage(profile.imagePath, defaultImageType: .user)
    }
}

extension ProfileViewController {
    public func fetchProfile() {
        reactor?.action.onNext(.fetchUserInfo)
    }
}



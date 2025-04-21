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
    
    // MARK: - Reactor
    typealias Reactor = ProfileViewReactor
    private var profileReactor: ProfileViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let reloadProfile: PublishSubject<Void> = .init()
    private let signOut: PublishSubject<Void> = .init()
    private let deleteAccount: PublishSubject<Void> = .init()
    
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
    
    private let profileEditButton: BaseButton = {
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
    
    private let signOutButton: BaseButton = {
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
        let sv = UIStackView(arrangedSubviews: [imageContainer, profileEditButton])
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
        let sv = UIStackView(arrangedSubviews: [signOutButton, resignButton])
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
        self.profileReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
        setAction()
    }

    // MARK: - UI Setup
    
    private func setupUI() {
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
        
        [notifyButton, policyButton, versionLabel, signOutButton, resignButton].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
    }
    
    private func setProfile(_ profile: UserInfo) {
        profileEditButton.title = profile.name
        profileImageView.kfSetimage(profile.imagePath, defaultImageType: .user)
    }
    
    // MARK: - Action
    private func setAction() {
        signOutButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.showSignOutAlert()
            })
            .disposed(by: disposeBag)
            
        resignButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.showDeleteAccountAlert()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Setup
extension ProfileViewController {
    private func setReactor() {
        reactor = profileReactor
    }
     
    func bind(reactor: Reactor) {
        inputBind(reactor)
        outputBind(reactor)
        setNotification(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        reloadProfile
            .map { Reactor.Action.fetchUserInfo }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        profileEditButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.editProfile) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        notifyButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.setNotify) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        policyButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.policy) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        signOut
            .map { Reactor.Action.signOut }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteAccount
            .map { Reactor.Action.deleteAccount }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        reactor.pulse(\.$userProfile)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, profile in
                vc.setProfile(profile)
            })
            .disposed(by: disposeBag)
    }
    
    private func setNotification(_ reactor: Reactor) {
        EventService.shared.addObservable(name: .editProfile)
            .map { Reactor.Action.fetchUserInfo }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

extension ProfileViewController {

    private func showSignOutAlert() {
        let signOutAction: DefaultAlertAction = .init(text: "네",
                                               textColor: ColorStyle.Default.white,
                                                      bgColor: ColorStyle.App.primary,
                                               completion: { [weak self] in
            self?.signOut.onNext(())
        })
        
        alertManager.showAlert(title: "로그아웃 하시겠어요?",
                               defaultAction: makeCancleAlertAction(),
                               addAction: [signOutAction])
    }
    
    private func showDeleteAccountAlert() {
        let deleteAccountAction: DefaultAlertAction = .init(text: "회원탈퇴",
                                                            textColor: ColorStyle.Default.white,
                                                            bgColor: ColorStyle.App.secondary,
                                                            completion: { [weak self] in
            self?.deleteAccount.onNext(())
        })
        
        alertManager.showAlert(title: "로그아웃 하시겠어요?",
                               defaultAction: makeCancleAlertAction(),
                               addAction: [deleteAccountAction])
    }
    
    private func makeCancleAlertAction() -> DefaultAlertAction {
        return .init(text: "아니오",
                     textColor: ColorStyle.Gray._01,
                     bgColor: ColorStyle.App.tertiary)
    }
}

extension ProfileViewController {
    public func fetchProfile() {
        reloadProfile.onNext(())
    }
}



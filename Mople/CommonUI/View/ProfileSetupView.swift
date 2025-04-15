//
//  ProfileSetupView.swift
//  Mople
//
//  Created by CatSlave on 2/10/25.
//

import UIKit
import RxSwift
import RxCocoa

enum ProfileViewType {
    case create
    case update
}

final class ProfileSetupView: UIView {
    // MARK: - UI Components
    private let imageContainerView = UIView()
    
    fileprivate let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .defaultIProfile
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    
    private let profileEditIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .editCircle
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    fileprivate let nameTextFieldView: LabeledTextFieldView = {
        let textField = LabeledTextFieldView(title: TextStyle.ProfileSetup.nameTitle,
                                              placeholder: TextStyle.ProfileSetup.typingName,
                                              maxTextCount: 15)
        return textField
    }()
    
    fileprivate let duplicateButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.ProfileSetup.checkBtnTitle,
                     font: FontStyle.Body1.semiBold,
                     normalColor: ColorStyle.Default.white)
        btn.setBgColor(normalColor: ColorStyle.App.secondary,
                       disabledColor: ColorStyle.Primary.disable2)
        btn.setRadius(6)
        btn.isEnabled = false
        return btn
    }()
    
    private let nameCheckContanierView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .vertical)
        return view
    }()
    
    fileprivate let nameCheckLabel = DuplicateLabel()
    
    fileprivate let completeButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(font: FontStyle.Title3.semiBold,
                     normalColor: ColorStyle.Default.white)
        btn.setBgColor(normalColor: ColorStyle.App.primary,
                       disabledColor: ColorStyle.Primary.disable)
        btn.setRadius(8)
        btn.isEnabled = false
        return btn
    }()
    
    private lazy var nameStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameTextFieldView, nameCheckContanierView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainerView, nameStackView, completeButton])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    // MARK: - Gesture
    fileprivate let imageTapGesture = UITapGestureRecognizer()
    
    // MARK: - Life Cycle
    init(type: ProfileViewType) {
        super.init(frame: .zero)
        handleViewType(type)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        setupLayout()
        setProfileViewGestrue()
        setupTextField()
    }
    
    // MARK: - UI Setup
    private func handleViewType(_ type: ProfileViewType) {
        switch type {
        case .create:
            completeButton.title = TextStyle.ProfileCreate.completedTitle
            mainStackView.spacing = 24
        case .update:
            completeButton.title = TextStyle.ProfileEdit.completedTitle
        }
    }
    
    private func setupLayout() {
        self.backgroundColor = .white
        self.addSubview(mainStackView)
        self.imageContainerView.addSubview(profileImageView)
        self.imageContainerView.addSubview(profileEditIcon)
        self.nameCheckContanierView.addSubview(nameCheckLabel)

        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        profileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
            make.top.bottom.equalToSuperview().inset(40)
        }
        
        profileEditIcon.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.bottom.equalTo(profileImageView)
        }

        nameCheckLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }

        completeButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    private func setupTextField() {
        nameTextFieldView.setInputTextField(view: duplicateButton, mode: .right)
    }
    
    // MARK: - Set Gesture
    private func setProfileViewGestrue() {
        self.profileImageView.addGestureRecognizer(imageTapGesture)
    }
}

// MARK: - Hlper
extension ProfileSetupView {
    public func setProfile(_ profile: UserInfo) {
        profileImageView.kfSetimage(profile.imagePath,
                                             defaultImageType: .user)
        setNickname(profile.name)
    }
    
    public func setNickname(_ name: String?) {
        nameTextFieldView.text = name
    }
    
    public func setImage(_ image: UIImage?) {
        profileImageView.image = image ?? .defaultUser
    }
    
    fileprivate func setDuplicate(_ isDuplicate: Bool?) {
       if let isDuplicate {
           nameCheckLabel.rx.isOverlap.onNext(isDuplicate)
           nameTextFieldView.textField.rx.isResign.onNext(!isDuplicate)
           duplicateButton.isEnabled = false
           completeButton.isEnabled = !isDuplicate
       } else {
           nameCheckLabel.isHidden = true
           completeButton.isEnabled = false
       }
   }
}

// MARK: - Reactive
extension Reactive where Base: ProfileSetupView {
    var editName: Observable<String?> {
        return base.nameTextFieldView.textField.rx.editText
    }
    
    var imageViewTapped: Observable<Void> {
        return base.imageTapGesture.rx.event
            .map { _ in }
    }
    
    var duplicateTapped: Observable<Void> {
        return base.duplicateButton.rx.controlEvent(.touchUpInside)
            .asObservable()
    }
    
    var completeTapped: Observable<Void> {
        return base.completeButton.rx.controlEvent(.touchUpInside)
            .asObservable()
    }
    
    var isDuplicateEnable: Binder<Bool> {
        return base.duplicateButton.rx.isEnabled
    }
    
    var isCompleteEnable: Binder<Bool> {
        return base.completeButton.rx.isEnabled
    }
    
    var isDuplicate: Binder<Bool?> {
        return Binder(base) { base, isDuplicate in
            base.setDuplicate(isDuplicate)
        }
    }
}

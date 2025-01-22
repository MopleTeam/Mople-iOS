//
//  ProfileSetupView.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

final class ProfileSetupViewController: UIViewController, View {

    typealias Reactor = ProfileSetupViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Manager
    private lazy var photoManager: PhotoManager = {
        let photoManager = PhotoManager(delegate: self,
                                        imageObserver: imageObserver.asObserver())
        return photoManager
    }()
    
    private let alertManager = AlertManager.shared

    // MARK: - Observer
    private let imageObserver: BehaviorSubject<UIImage?> = .init(value: nil)
    private let validNameObserver: BehaviorSubject<Bool?> = .init(value: nil)
    private let loadingObserver: AnyObserver<Bool>
    private let completionObserver: AnyObserver<(nickname: String, image: UIImage?)>

    // MARK: - Gesture
    private let imageTapGesture = UITapGestureRecognizer()
    
    // MARK: - UI Components
    private let imageContainerView = UIView()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .defaultIProfile
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let profileEditIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .editCircle
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let nameView: LabeledTextFieldView = {
        let textField = LabeledTextFieldView(title: TextStyle.ProfileSetup.nameTitle,
                                              placeholder: TextStyle.ProfileSetup.typingName,
                                              maxTextCount: 15)
        return textField
    }()
    
    private let duplicateButton: BaseButton = {
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
    
    private let nameCheckLabel = DuplicateLabel()
    
    private let completionButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.DatePicker.completedTitle,
                     font: FontStyle.Title3.semiBold,
                     normalColor: ColorStyle.Default.white)
        btn.setBgColor(normalColor: ColorStyle.App.primary,
                       disabledColor: ColorStyle.Primary.disable)
        btn.setRadius(8)
        btn.isEnabled = false
        return btn
    }()
    
    private lazy var nameStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameView, nameCheckContanierView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainerView, nameStackView, completionButton])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    // MARK: - LifeCycle
    init(reactor: ProfileSetupViewReactor,
         lodingObserver: AnyObserver<Bool>,
         completionObserver: AnyObserver<(nickname: String, image: UIImage?)>) {
        print(#function, #line, "LifeCycle Test ProfileSetupView Created" )
        self.completionObserver = completionObserver
        self.loadingObserver = lodingObserver
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test ProfileSetupView Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        initalSetup()
        setBind()
    }

    // MARK: - UI Setup
    private func initalSetup() {
        setupLayout()
        setupTextField()
        setupKeyboardDismissGestrue()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(mainStackView)
        self.imageContainerView.addSubview(profileImageView)
        self.imageContainerView.addSubview(profileEditIcon)
        self.nameCheckContanierView.addSubview(nameCheckLabel)

        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(UIScreen.getDefatulBottomInset())
        }

        profileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
            make.top.bottom.equalToSuperview().inset(40)
        }
        
        profileImageView.layer.cornerRadius = 40
        
        profileEditIcon.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.bottom.equalTo(profileImageView)
        }

        nameCheckLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }

        completionButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }

    private func setupTextField() {
        nameView.setInputTextField(view: duplicateButton, mode: .right)
     }
    
    // MARK: - 외부 바인딩
    func bind(reactor: ProfileSetupViewReactor) {
        setInput(reactor: reactor)
        setOutput(reactor: reactor)
    }
    
    private func setInput(reactor: Reactor) {
        self.nameView.textField.rx.editEvent
            .map({ [weak self] in
                self?.nameView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            })
            .map { Reactor.Action.setName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.imageObserver
            .skip(1)
            .map { Reactor.Action.setImage($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.duplicateButton.rx.controlEvent(.touchUpInside)
            .compactMap({ _ in self.nameView.text })
            .map { Reactor.Action.duplicateCheck(name: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setOutput(reactor: Reactor) {
        reactor.pulse(\.$previousProfile)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, profile in
                vc.handleSetupView(previousProfile: profile)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$canCheckDuplication)
            .asDriver(onErrorJustReturn: false)
            .drive(self.duplicateButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$canCheckCompletion)
            .asDriver(onErrorJustReturn: false)
            .drive(self.completionButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isDuplicationName)
            .map({ $0 })
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, isDuplicate in
                vc.handleValidName(isDuplicate)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$message)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "오류가 발생했습니다.")
            .drive(with: self, onNext: { vc, message in
                vc.alertManager.showAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .skip(1)
            .asDriver(onErrorJustReturn: false)
            .drive(loadingObserver)
            .disposed(by: disposeBag)
    }
    
    // MARK: - 내부 바인딩
    private func setBind() {
        setAction()
        setEditImageBind()
        setGeestureBind()
    }
    
    private func setAction() {
        completionButton.rx.controlEvent(.touchUpInside)
            .debug()
            .compactMap { _ in self.makeProfile() }
            .bind(to: completionObserver)
            .disposed(by: disposeBag)
    }

    // 이미지 변경
    private func setEditImageBind() {
        imageObserver
            .map({ $0 ?? .defaultUser })
            .asDriver(onErrorJustReturn: .defaultUser)
            .drive(profileImageView.rx.image)
            .disposed(by: disposeBag)
    }

    // 제스처
    private func setGeestureBind() {
        self.profileImageView.addGestureRecognizer(imageTapGesture)
        
        imageTapGesture.rx.event
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.showPhotos()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 입력 제한
extension ProfileSetupViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= 15
    }
}

// MARK: - 랜덤 닉네임
extension ProfileSetupViewController {
    public func setRandomNickname(_ name: String) {
        duplicateButton.isEnabled = true
        nameView.text = name
    }
}

// MARK: - 프로필 생성 및 적용
extension ProfileSetupViewController {
    private func makeProfile() -> (String, UIImage?)? {
        guard let nickName = reactor?.currentState.name else {
            return nil
        }
        let image = reactor?.currentState.image
        return (nickName, image)
    }
}

// MARK: - 이미지 선택
extension ProfileSetupViewController {
    private func showPhotos() {
        let selectPhotoAction = alertManager.makeAction(title: "기본 이미지로 변경", completion: setDefaultImage)
        let defaultPhotoAction = alertManager.makeAction(title: "앨범에서 사진 선택", completion: presentPhotos)
        
        alertManager.showActionSheet(actions: [selectPhotoAction, defaultPhotoAction])
    }
    
    private func presentPhotos() {
        photoManager.requestPhotoLibraryPermission()
    }
    
    private func setDefaultImage() {
        imageObserver.onNext(nil)
    }
}

// MARK: - 닉네임 중복검사
extension ProfileSetupViewController {
    private func handleValidName(_ isDuplicate: Bool?) {
        if let isDuplicate {
            nameCheckLabel.rx.isOverlap.onNext(isDuplicate)
            nameView.textField.rx.isResign.onNext(!isDuplicate)
            duplicateButton.isEnabled = false
            completionButton.isEnabled = !isDuplicate
        } else {
            nameCheckLabel.isHidden = true
            completionButton.isEnabled = false
        }
    }
}

// MARK: - 프로필 생성, 편집
extension ProfileSetupViewController {
    private func handleSetupView(previousProfile: UserInfo?) {
        if let previousProfile {
            completionButton.title = TextStyle.ProfileEdit.completedTitle
            setProfile(previousProfile)
        } else {
            completionButton.title = TextStyle.ProfileCreate.completedTitle
            mainStackView.spacing = 24
        }
    }
    
    private func setProfile(_ profile: UserInfo) {
        _ = self.profileImageView.kfSetimage(profile.imagePath,
                                             defaultImageType: .user)
        nameView.text = profile.name
    }
}

extension ProfileSetupViewController: KeyboardDismissable {
    private func setupKeyboardDismissGestrue() {
        setupTapKeyboardDismiss()
    }
}


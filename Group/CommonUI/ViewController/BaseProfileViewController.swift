//
//  ProfileSetupView.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa
import ReactorKit

enum ButtonType {
    case check
    case next
}

final class BaseProfileViewController: UIViewController, View {
    
    typealias Reactor = ProfileSetupViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private lazy var photoManager: PhotoManager = {
        let photoManager = PhotoManager(delegate: self,
                                        imageObserver: imageObserver.asObserver())
        return photoManager
    }()
    
    private lazy var alertManager = AlertManager.shared
    
    // MARK: - Observer
    private let imageObserver: BehaviorSubject<UIImage?> = .init(value: nil)
    
    // MARK: - Gesture
    private let imageTapGesture = UITapGestureRecognizer()
    private let backTapGesture = UITapGestureRecognizer()
    
    // MARK: - UI Components
    private let imageContainerView : UIView = {
        let view = UIView()
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppDesign.Profile.selectImage
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let nameTitle = BaseLabel(configure: AppDesign.Profile.nameTitle)
    
    private let nameTextFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "F6F8FA")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameTextField = BaseTextField(configure: AppDesign.Profile.nameText)
    
    private let nameCheckButton: BaseButton = {
        let button = BaseButton(backColor: AppDesign.Profile.checkButtonBackColor,
                                radius: 6,
                                configure: AppDesign.Profile.checkButton)
        button.tag = 0
        return button
    }()
    
    private let nameCheckContanierView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .vertical)
        return view
    }()
    
    private let nameCheckLabel = BaseLabel(configure: AppDesign.Profile.checkTitle)
    
    private var nextButton: BaseButton = {
        let button = BaseButton(backColor: AppDesign.Profile.nextButtonBackColor,
                                   radius: 8,
                                   configure: AppDesign.Profile.nextButton)
        button.tag = 1
        button.isEnabled = false
        return button
    }()
    
    private lazy var nameStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameTitle, nameTextFieldContainer, nameCheckContanierView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainerView, nameStackView, nextButton])
        sv.axis = .vertical
        sv.spacing = 24
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - LifeCycle
    init(reactor: ProfileSetupViewReactor) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        setupAction()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
        setupTextField()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(mainStackView)
        self.imageContainerView.addSubview(profileImageView)
        self.nameTextFieldContainer.addSubview(nameTextField)
        self.nameCheckContanierView.addSubview(nameCheckLabel)

        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }

        profileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
            make.top.bottom.equalToSuperview().inset(40)
        }
        
        profileImageView.layer.cornerRadius = 40

        nameTextFieldContainer.snp.makeConstraints { make in
            make.height.equalTo(56)
        }

        nameTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }

        nameCheckLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    private func setupTextField() {
         self.nameTextField.rightViewMode = .always
         self.nameTextField.rightView = nameCheckButton
         self.nameTextField.delegate = self
     }
    
    // MARK: - Binding
    func bind(reactor: ProfileSetupViewReactor) {
        setInput(reactor: reactor)
        setOutput(reactor: reactor)
    }
    
    private func setInput(reactor: Reactor) {
        self.nameCheckButton.rx.controlEvent(.touchUpInside)
            .filter({ _ in self.checkNicknameValidator() })
            .compactMap({ _ in self.nameTextField.text })
            .map { Reactor.Action.checkNickname(name: $0,
                                                tag: self.nameCheckButton.tag) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.nextButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.setProfile(profile: self.makeProfile(),
                                             tag: self.nextButton.tag) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setOutput(reactor: Reactor) {
        reactor.pulse(\.$randomName)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, name in
                vc.nameTextField.text = name
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$nameOverlap)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: true)
            .drive(with: self, onNext: { vc, isOverlap in
                vc.checkNickName(isOverlap: isOverlap)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "오류가 발생했습니다.")
            .drive(with: self, onNext: { vc, message in
                vc.alertManager.showAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$buttonLoading)
            .compactMap { $0 }
            .subscribe(on: MainScheduler.instance)
            .bind(with: self, onNext: { vc, isLoad in
                vc.setButtonIndicator(isLoading: isLoad.status, tag: isLoad.tag)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action
    private func setupAction() {
        self.view.addGestureRecognizer(backTapGesture)
        self.profileImageView.addGestureRecognizer(imageTapGesture)

        imageObserver
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: AppDesign.Profile.defaultImage)
            .drive(with: self, onNext: { vc, image in
                vc.setImageView(image: image)
            })
            .disposed(by: disposeBag)
        
        backTapGesture.rx.event
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        imageTapGesture.rx.event
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.showPhotos()
            })
            .disposed(by: disposeBag)
    }
}

extension BaseProfileViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""

        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return newText.count <= 10
    }
    
    
    /// 완료버튼 활성화 후 텍스트 입력 시 설정값 초기화
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if nextButton.isEnabled {
            resetCheck()
        }
    }
}

// MARK: - 프로필 생성 및 적용
extension BaseProfileViewController {
    private func makeProfile() -> Profile {
        let nickName = nameTextField.text
        let image = try? imageObserver.value()
        return .init(name: nickName, image: image)
    }
    
    public func setProfile(_ profile: Profile) {
        self.setImageView(image: profile.image)
        self.nameTextField.text = profile.name
    }
}

// MARK: - 이미지 선택
extension BaseProfileViewController {
    private func showPhotos() {
        let selectPhotoAction = alertManager.makeAction(title: "기본 이미지로 변경", completion: setDefaultImage)
        let defaultPhotoAction = alertManager.makeAction(title: "앨범에서 사진 선택", completion: presentPhotos)
        
        alertManager.showActionSheet(actions: [selectPhotoAction, defaultPhotoAction])
    }
    
    private func presentPhotos() {
        photoManager.requestPhotoLibraryPermission()
    }
    
    private func setDefaultImage() {
        self.profileImageView.image = AppDesign.Profile.defaultImage
    }
    
    private func setImageView(image: UIImage?) {
        print(#function, #line)
        self.profileImageView.clipsToBounds = true
        profileImageView.image = image
    }
}

// MARK: - Helper
extension BaseProfileViewController {

    private func setButtonIndicator(isLoading: Bool,
                                    tag: Int) {
        view.isUserInteractionEnabled = !isLoading
        
        switch tag {
        case 0:
                self.nameCheckButton.loading(status: isLoading)
                self.nameTextField.updateLayout()
        case 1:
            nextButton.loading(status: isLoading)
        default:
            break
        }
    }
    
    private func checkNickName(isOverlap: Bool) {
        nameCheckLabel.isOverlapCheck = isOverlap
        nextButton.isEnabled = !isOverlap
        endEditNameTextField(isOverlap: isOverlap)
    }
    
    private func resetCheck() {
        nameCheckLabel.isOverlapCheck = false
        nextButton.isEnabled = false
    }
    
    private func endEditNameTextField(isOverlap: Bool?) {
        if !(isOverlap ?? false) {
            self.nameTextField.resignFirstResponder()
        }
    }
    
    private func checkNicknameValidator() -> Bool {
        let valid = Validator.checkNickname(name: self.nameTextField.text)
        
        switch valid {
        case .success:
            return true
        default:
            alertManager.showAlert(message: valid.info)
            return false
        }
    }
}

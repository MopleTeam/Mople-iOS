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

class ProfileSetupViewController: UIViewController, StoryboardView, Alertable {
    typealias Reactor = ProfileSetupViewReactor
    
    // MARK: - Variables
    private let photoManager: PhotoService
    
    var disposeBag = DisposeBag()
    
    // MARK: - Output Action Variables
    private let selectedImage = BehaviorRelay<Data>(value: Data())
    
    private let imageTapGesture = UITapGestureRecognizer()
    private let backTapGesture = UITapGestureRecognizer()
    
    // MARK: - UI Components
    private let mainTitle: DefaultLabel = {
        let label = DefaultLabel(configure: AppDesign.Profile.main)
        label.numberOfLines = 2
        return label
    }()
    
    private let imageContainerView : UIView = {
        let view = UIView()
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppDesign.Profile.selectImage
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let nameTitle = DefaultLabel(configure: AppDesign.Profile.nameTitle)
    
    private let nameTextFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "F6F8FA")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameTextField = DefaultTextField(configure: AppDesign.Profile.nameText)
    
    private let nameCheckButton = DefaultButton(backColor: AppDesign.Profile.checkButtonBackColor,
                                                radius: 6,
                                                textConfigure: AppDesign.Profile.checkButton)
    
    private let nameCheckContanierView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .vertical)
        return view
    }()
    
    private let nameCheckLabel = DefaultLabel(configure: AppDesign.Profile.checkTitle)
    
    private lazy var nameStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameTitle, nameTextFieldContainer, nameCheckContanierView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private var nextButton: DefaultButton = {
        let button = DefaultButton(backColor: AppDesign.Profile.nextButtonBackColor,
                                   radius: 8,
                                   textConfigure: AppDesign.Profile.nextButton)
        button.isEnabled = false
        return button
    }()
    
    private lazy var profileStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [mainTitle, imageContainerView, nameStackView, nextButton])
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 28, left: 20, bottom: 28, right: 20)
        return sv
    }()
    
    
    // MARK: - LifeCycle
    init(photoManager: PhotoService,
         reactor: ProfileSetupViewReactor) {
        defer { self.reactor = reactor }
        self.photoManager = photoManager
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
        setupTextField()
        setupLayout()
        
        setupAction()
    }

    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(profileStackView)
        self.imageContainerView.addSubview(profileImageView)
        self.nameTextFieldContainer.addSubview(nameTextField)
        self.nameCheckContanierView.addSubview(nameCheckLabel)

        profileStackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
            make.top.bottom.equalToSuperview().inset(40)
        }

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
    
    // MARK: - Selectors
    
    
    /// 비즈니스 로직 실행
    func bind(reactor: ProfileSetupViewReactor) {
    
        self.selectedImage
            .map { Reactor.Action.selectedImage(image: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.nameCheckButton.rx.controlEvent(.touchUpInside)
            .filter({ _ in
                self.checkNicknameValidator()
            })
            .compactMap({ _ in
                return self.nameTextField.text
            })
            .map { Reactor.Action.checkNickname(name: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.nextButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.makeProfile }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$randomName)
            .filter({ _ in
                self.nameTextField.text?.isEmpty ?? true
            })
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, name in
                vc.nameTextField.text = name
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$nameOverlap)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, isOverlap in
                vc.checkNickName(isOverlap: isOverlap)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "오류가 발생했습니다.")
            .drive(with: self, onNext: { vc, message in
//                vc.showAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .compactMap { $0 }
            .subscribe(on: MainScheduler.instance)
            .bind(with: self, onNext: { vc, isLoad in
                vc.setButtonIndicator(isLoading: isLoad.status, type: isLoad.type)
                vc.setUserInteraction(isLoading: !isLoad.status)
            })
            .disposed(by: disposeBag)
    }
    
    /// 단순 UI 액션
    private func setupAction() {
        self.view.addGestureRecognizer(backTapGesture)
        self.profileImageView.addGestureRecognizer(imageTapGesture)

        backTapGesture.rx.event
            .bind(with: self, onNext: { vc, _ in
                vc.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        imageTapGesture.rx.event
            .bind(with: self, onNext: { vc, _ in
                let selectPhotoAction = vc.makeAction(title: "기본 이미지로 변경", completion: vc.setDefaultImage)
                let defaultPhotoAction = vc.makeAction(title: "앨범에서 사진 선택", completion: vc.presentPhotos)
                
                vc.showActionSheet(actions: [selectPhotoAction, defaultPhotoAction])
            }).disposed(by: disposeBag)
    }
}

// MARK: - Helper
extension ProfileSetupViewController {
    private func setUserInteraction(isLoading: Bool) {
        view.isUserInteractionEnabled = isLoading
    }
    
    private func setButtonIndicator(isLoading: Bool,
                                    type: ProfileSetupViewReactor.ButtonType) {
        switch type {
        case .check:
            nameCheckButton.loading(status: isLoading)
            nameTextField.updateLayout()
        case .next:
            nextButton.loading(status: isLoading)
        }
    }
    
    private func presentPhotos() {
        photoManager.requestPhotoLibraryPermission(delegate: self)
    }
    
    private func setDefaultImage() {
        self.profileImageView.image = AppDesign.Profile.defaultImage
    }
    
    private func checkNickName(isOverlap: Bool?) {
        guard let isOverlap = isOverlap else { return }
        
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
        case .countOver, .strange, .empty:
            self.showAlert(message: valid.info)
            return false
        }
    }
}

// MARK: - Photos
extension ProfileSetupViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemprovider = results.first?.itemProvider,
        itemprovider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemprovider.loadObject(ofClass: UIImage.self) { [weak self] image , error  in
            guard let self = self else { return }
            
            if let error {
                #warning("Present Alert")
                print(error)
            }
            
            if let selectedImage = image as? UIImage,
               let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
                print("이미지 크기 : \(imageData)")
                self.selectedImage.accept(imageData)
                
                DispatchQueue.main.async {
                    let targetSize = self.profileImageView.frame.size
                    
                    let resizeImage = selectedImage.resize(size: targetSize, cornerRadius: targetSize.width/2)
                    self.profileImageView.image = resizeImage
                }
            }
        }
    }
}

extension ProfileSetupViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""

        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return newText.count <= 10
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if nextButton.isEnabled {
            resetCheck()
        }
    }
}




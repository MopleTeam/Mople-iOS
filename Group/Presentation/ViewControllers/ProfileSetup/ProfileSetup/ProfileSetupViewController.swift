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
    
    enum ViewType {
        case create
        case edit(_ previousProfile: ProfileInfo)
    }
    
    typealias Reactor = ProfileFormViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Manager
    private lazy var photoManager: PhotoManager = {
        let photoManager = PhotoManager(delegate: self,
                                        imageObserver: imageObserver.asObserver())
        return photoManager
    }()
    
    private lazy var alertManager = AlertManager.shared
    
    // MARK: - Variables
    private let viewType: ViewType
    
    // MARK: - Observer
    private let imageObserver: BehaviorSubject<UIImage?> = .init(value: nil)
    private let validNameObserver: BehaviorSubject<Bool?> = .init(value: nil)
    
    // MARK: - Gesture
    private let imageTapGesture = UITapGestureRecognizer()
    private let backTapGesture = UITapGestureRecognizer()
    
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

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = TextStyle.ProfileSetup.nameTitle
        label.font = FontStyle.Title3.semiBold
        label.textColor = ColorStyle.Gray._01
        return label
    }()
    
    private let nameTextFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "F6F8FA")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        
        textField.font = FontStyle.Body1.regular
        textField.textColor = ColorStyle.Gray._01
        return textField
    }()
    
    private let duplicateButton: DuplicateButton = {
        let btn = DuplicateButton()
        btn.setTitle(text: TextStyle.ProfileSetup.checkBtnTitle,
                     font: FontStyle.Body1.semiBold,
                     color: ColorStyle.Default.white)
        return btn
    }()
    
    private let nameCheckContanierView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .vertical)
        return view
    }()
    
    private let nameCheckLabel = DuplicateLabel()
    
    private let completionButton = CompletionButton()
    
    private lazy var nameStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameLabel, nameTextFieldContainer, nameCheckContanierView])
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
    init(type: ViewType,
         reactor: ProfileFormViewReactor) {
        self.viewType = type
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        setBind()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
        setupTextField()
        configureView()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(mainStackView)
        self.imageContainerView.addSubview(profileImageView)
        self.imageContainerView.addSubview(profileEditIcon)
        self.nameTextFieldContainer.addSubview(nameTextField)
        self.nameCheckContanierView.addSubview(nameCheckLabel)

        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(UIScreen.hasNotch() ? 0 : 28)
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

        completionButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    private func setupTextField() {
         self.nameTextField.rightViewMode = .always
         self.nameTextField.rightView = duplicateButton
         self.nameTextField.delegate = self
     }
    
    // MARK: - 외부 바인딩
    func bind(reactor: ProfileFormViewReactor) {
        setInput(reactor: reactor)
        setOutput(reactor: reactor)
    }
    
    private func setInput(reactor: Reactor) {
        self.duplicateButton.rx.controlEvent(.touchUpInside)
            .compactMap({ _ in self.nameTextField.text })
            .map { Reactor.Action.checkNickname(name: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.completionButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.setProfile(profile: self.makeProfile()) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setOutput(reactor: Reactor) {
        reactor.pulse(\.$randomName)
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, name in
                vc.duplicateButton.rx.isEnabled.onNext(true)
                vc.nameTextField.rx.text.onNext(name)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$nameOverlap)
            .compactMap({ $0 })
            .map({ !$0 })
            .asDriver(onErrorJustReturn: false)
            .drive(self.validNameObserver)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$message)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "오류가 발생했습니다.")
            .drive(with: self, onNext: { vc, message in
                vc.alertManager.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 내부 바인딩
    private func setBind() {
        setValidBind()
        setEditImageBind()
        setEditNameBind()
        setGeestureBind()
    }
    
    private func setValidBind() {
        Observable.combineLatest(imageObserver, validNameObserver)
            .do(onNext: { print(#function, #line, "valid : \($0)" ) })
            .skip(1)
            .asDriver(onErrorJustReturn: (nil, nil))
            .compactMap(checkContentValid(content:))
            .drive(completionButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        validNameObserver
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isValid in
                vc.duplicateButton.rx.isEnabled.onNext(false)
                vc.nameCheckLabel.rx.isOverlap.onNext(!isValid)
                vc.nameTextField.rx.isResign.onNext(isValid)
            })
            .disposed(by: disposeBag)
    }
    
    // 이미지 변경
    private func setEditImageBind() {
        imageObserver
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: .defaultIProfile)
            .drive(profileImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    private func setEditNameBind() {
        nameTextField.rx.controlEvent(.editingChanged)
            .asDriver(onErrorJustReturn: ())
            .do(onNext: { _ in
                self.nameCheckLabel.rx.isHidden.onNext(true)
                self.validNameObserver.onNext(nil)
            })
            .map({ _ in self.isChangedName() })
            .drive(with: self, onNext: { vc, isChanged in
                vc.duplicateButton.rx.isEnabled.onNext(isChanged)
            })
            .disposed(by: disposeBag)
    }

    // 제스처
    private func setGeestureBind() {
        self.view.addGestureRecognizer(backTapGesture)
        self.profileImageView.addGestureRecognizer(imageTapGesture)
        
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

// MARK: - 입력 제한
extension ProfileSetupViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }

        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= 10
    }
}

// MARK: - 프로필 생성 및 적용
extension ProfileSetupViewController {
    private func makeProfile() -> (String?, UIImage?) {
        let nickName = nameTextField.text
        let image = try? imageObserver.value()
        return (nickName, image)
    }
    
    private func setProfile(_ profile: ProfileInfo) {
        _ = self.profileImageView.kfSetimage(profile.imagePath)
        self.nameTextField.text = profile.name
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
        imageObserver.onNext(.defaultIProfile)
    }
}

// MARK: - 프로필 변경여부
extension ProfileSetupViewController {
    
    /// 이미지 변경, 닉네임 중복여부에 따라서 완료버튼 활성화 유무
    /// - 이미지가 입력된 경우
    ///     - 닉네임 중복검사 값(nil인 경우 닉네임 변경여부)
    /// - 이미지가 없는 경우
    ///     - 닉네임 중복검사 값(nil인 경우 false)
    private func checkContentValid(content: (image: UIImage?, nicknameOverlap: Bool?)) -> Bool {
        if content.image != nil {
            return content.nicknameOverlap ?? !self.isChangedName()
        } else {
            return content.nicknameOverlap ?? false
        }
    }
    
    /// 닉네임 변경여부
    /// - 프로필 생성 뷰 타입 : 이전 값이 없음으로 true
    /// - 프로필 편집 뷰 타입 : 이전 값과 비교해서 return
    private func isChangedName() -> Bool {
        switch viewType {
        case .create:
            return true
        case .edit(let previousProfile):
            return self.nameTextField.text != previousProfile.name
        }
    }
}

// MARK: - 프로필 생성, 편집에
extension ProfileSetupViewController {
    private func configureView() {
        switch viewType {
        case .create:
            mainStackView.spacing = 24
            completionButton.setTitle(TextStyle.ProfileCreate.completedTitle, for: .normal)
        case .edit(let previousProfile):
            completionButton.setTitle(TextStyle.ProfileEdit.completedTitle, for: .normal)
            setProfile(previousProfile)
        }
    }
}

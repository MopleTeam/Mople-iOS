//
//  GroupCreateViewController.swift
//  Group
//
//  Created by CatSlave on 11/16/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

final class GroupCreateViewController: DefaultViewController, KeyboardEvent {
    var transformView: UIView { self.view }
    
    var contentView: UIView { self.completionButton }
    
    var disposeBag = DisposeBag()
    
    // MARK: - Manager
    private lazy var photoManager: PhotoManager = {
        let photoManager = PhotoManager(delegate: self,
                                        imageObserver: imageObserver.asObserver())
        return photoManager
    }()
    
    // MARK: - Observer
    private let imageObserver: BehaviorSubject<UIImage?> = .init(value: nil)
    
    private lazy var leftButtonObserver = addLeftButton()
    
    // MARK: - Gesture
    private let imageTapGesture = UITapGestureRecognizer()
    private let backTapGesture = UITapGestureRecognizer()
    
    // MARK: - UI Components
    private let imageContainerView = UIView()
    
    private let groupImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = .defaultIProfile
        imageView.backgroundColor = .systemMint
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private let imageEditIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .editCircle
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = TextStyle.CreateGroup.groupTitle
        label.font = FontStyle.Title3.semiBold
        label.textColor = ColorStyle.Gray._01
        return label
    }()
    
    // 플레이스 홀더 글자 색
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = FontStyle.Body1.regular
        textField.textColor = ColorStyle.Gray._01
        textField.placeholder = TextStyle.CreateGroup.placeHolder
        textField.backgroundColor = ColorStyle.BG.input
        return textField
    }()
    
    // asciiCapable : 영어랑 숫자만 입력가능
    // webSearch : 기본에서 . 이 있음
    // twitter : # 이 있음
    // emailAddress : @
    
    private let completionButton: CompletionButton = {
        let btn = CompletionButton()
        btn.setTitle(TextStyle.CreateGroup.completedTitle, for: .normal)
        return btn
    }()
    
    private lazy var nameStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, titleTextField])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainerView, nameStackView])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    override init(title: String?) {
        super.init(title: title)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        setGeestureBind()
        setupKeyboardEvent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObserver()
    }
    
    private func setupUI() {
        setTextfieldUI()
        setupLayout()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = ColorStyle.Default.white
        self.view.addSubview(mainStackView)
        self.view.addSubview(completionButton)
        self.imageContainerView.addSubview(groupImageView)
        self.imageContainerView.addSubview(imageEditIcon)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        completionButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(mainStackView)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(UIScreen.hasNotch() ? 0 : 28)
            make.height.equalTo(56)
        }

        imageContainerView.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        groupImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
        
        imageEditIcon.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(groupImageView).offset(6)
            make.size.equalTo(24)
        }
    }
    
    private func setTextfieldUI() {
        titleTextField.layer.cornerRadius = 8
        titleTextField.leftView = .init(frame: .init(x: 0, y: 0, width: 16, height: 0))
        titleTextField.rightView = .init(frame: .init(x: 0, y: 0, width: 16, height: 0))
        titleTextField.leftViewMode = .always
        titleTextField.rightViewMode = .always
    }
    
    // MARK: - Binding
    func bind() {
        leftButtonObserver
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setGeestureBind() {
        self.view.addGestureRecognizer(backTapGesture)
        self.groupImageView.addGestureRecognizer(imageTapGesture)
        
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

// MARK: - 이미지 선택
extension GroupCreateViewController {
    private func showPhotos() {
        photoManager.requestPhotoLibraryPermission()
    }
}

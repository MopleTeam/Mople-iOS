//
//  GroupCreateViewController.swift
//  Group
//
//  Created by CatSlave on 11/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class GroupCreateViewController: DefaultViewController, View, KeyboardEvent {
    
    typealias Reactor = GroupCreateViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Handle KeyboardEvent
    var superView: UIView { self.view }
    var floatingView: UIView { self.completionButton }
    var scrollView: UIScrollView { self.mainView }
    var overlappingView: UIView { self.titleTextField }
    var floatingViewBottom: Constraint?
    
    // MARK: - Manager
    private lazy var photoManager: PhotoManager = {
        let photoManager = PhotoManager(delegate: self,
                                        imageObserver: imageObserver.asObserver())
        
        return photoManager
    }()
    
    private lazy var alertManager = AlertManager.shared
    
    // MARK: - Observer
    private let imageObserver: BehaviorSubject<UIImage?> = .init(value: nil)
    
    private lazy var leftButtonObserver = addLeftButton()
    
    // MARK: - Gesture
    private let imageTapGesture = UITapGestureRecognizer()
    private let backTapGesture = UITapGestureRecognizer()
    
    // MARK: - UI Components
    private let mainView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
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
    
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint
        return view
    }()
    
    private let completionButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.CreateGroup.completedTitle,
                     font: FontStyle.Title3.semiBold,
                     color: ColorStyle.Default.white)
        btn.setBgColor(ColorStyle.App.primary)
        btn.layer.contents = 8
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
        let sv = UIStackView(arrangedSubviews: [imageContainerView, nameStackView, emptyView])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    init(title: String?,
         reactor: GroupCreateViewReactor) {
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        self.view.addSubview(mainView)
        self.view.addSubview(completionButton)
        self.mainView.addSubview(contentView)
        self.contentView.addSubview(mainStackView)
        self.imageContainerView.addSubview(groupImageView)
        self.imageContainerView.addSubview(imageEditIcon)
        
        mainView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(mainView.contentLayoutGuide)
            make.width.equalTo(mainView.frameLayoutGuide.snp.width)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        completionButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(56)
            floatingViewBottom = make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(UIScreen.hasNotch() ? 0 : 28).constraint
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
        titleTextField.delegate = self
    }
    
    // MARK: - Binding
    func bind(reactor: GroupCreateViewReactor) {
        self.completionButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.setGroup(group: self.makeGroup()) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$message)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "오류가 발생했습니다.")
            .drive(with: self, onNext: { vc, message in
                vc.alertManager.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupAction() {
        setupButton()
        setGesture()
        setEditImage()
    }
    
    private func setupButton() {
        leftButtonObserver
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setGesture() {
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
    
    // 이미지 변경
    private func setEditImage() {
        imageObserver
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: .defaultIProfile)
            .drive(groupImageView.rx.image)
            .disposed(by: disposeBag)
    }
}

// MARK: - 그룹 생성 및 적용
extension GroupCreateViewController {
    private func makeGroup() -> (String?, UIImage?) {
        let nickName = titleTextField.text
        let image = try? imageObserver.value()
        return (nickName, image)
    }
}

// MARK: - 이미지 선택
extension GroupCreateViewController {
    private func showPhotos() {
        photoManager.requestPhotoLibraryPermission()
    }
}

extension GroupCreateViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= 30
    }
}

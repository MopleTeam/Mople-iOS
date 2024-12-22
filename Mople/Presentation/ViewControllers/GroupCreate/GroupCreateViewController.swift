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

final class GroupCreateViewController: TitleNaviViewController, View, KeyboardEvent {
    
    typealias Reactor = GroupCreateViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Handle KeyboardEvent
    var superView: UIView { self.view }
    var floatingView: UIView { self.completionButton }
    var scrollView: UIScrollView { self.mainView }
    var overlappingView: UIView { self.inputTextField }
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
    
    private let inputTextField: LabeledTextField = {
        let textField = LabeledTextField(title: TextStyle.CreateGroup.groupTitle,
                                              placeholder: TextStyle.CreateGroup.placeholder,
                                              maxTextCount: 30)
        return textField
    }()
    
    private let completionButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.CreateGroup.completedTitle,
                     font: FontStyle.Title3.semiBold,
                     color: ColorStyle.Default.white)
        btn.setBgColor(ColorStyle.App.primary, disabledColor: ColorStyle.Primary.disable)
        btn.setRadius(8)
        return btn
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainerView, inputTextField])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    init(title: String?,
         reactor: GroupCreateViewReactor) {
        print(#function, #line, "LifeCycle Test GroupCreate View Created" )
        super.init(title: title)
        self.reactor = reactor
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test GroupCreate View Deinit" )
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
        setupLayout()
        setNaviItem()
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
            floatingViewBottom = make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                .inset(UIScreen.getAdditionalBottomInset()).constraint
        }

        imageContainerView.snp.makeConstraints { make in
            make.height.equalTo(160)
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
    
    private func setNaviItem() {
        self.setBarItem(type: .left, image: .arrowBack)
    }
    
    private func setupAction() {
        setupButton()
        setGesture()
        setEditImage()
    }
    
    private func setupButton() {
        leftItemEvent
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
        let nickName = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
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

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

final class CreateMeetViewController: TitleNaviViewController, View, KeyboardResponsive {
    
    typealias Reactor = CreateMeetViewReactor
    
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
    
    private let alertManager = AlertManager.shared
    
    // MARK: - Observer
    private let imageObserver: BehaviorSubject<UIImage?> = .init(value: nil)
        
    // MARK: - Gesture
    private let imageTapGesture = UITapGestureRecognizer()
    
    // MARK: - UI Components
    private let mainView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let imageContainerView = UIView()
    
    private let thumnailView: UIImageView = {
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
    
    private let inputTextField: LabeledTextFieldView = {
        let textField = LabeledTextFieldView(title: TextStyle.CreateGroup.groupTitle,
                                              placeholder: TextStyle.CreateGroup.placeholder,
                                              maxTextCount: 30)
        return textField
    }()
    
    private let completionButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.CreateGroup.completedTitle,
                     font: FontStyle.Title3.semiBold,
                     normalColor: ColorStyle.Default.white)
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
         reactor: CreateMeetViewReactor) {
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
        initalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardEvent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObserver()
    }
    
    private func initalSetup() {
        setupUI()
        setGesture()
        setObserver()
    }
    
    // MARK: - UI Setup
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
        self.imageContainerView.addSubview(thumnailView)
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
        
        thumnailView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
        
        imageEditIcon.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(thumnailView).offset(6)
            make.size.equalTo(24)
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    // MARK: - Binding
    func bind(reactor: CreateMeetViewReactor) {
        self.completionButton.rx.controlEvent(.touchUpInside)
            .compactMap({ [weak self] in
                self?.makeMeet()
            })
            .map { Reactor.Action.requestMeetCreate(group: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        naviBar.leftItemEvent
            .map { Reactor.Action.endFlow }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isLoading in
                vc.rx.isLoading.onNext(isLoading)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$message)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "오류가 발생했습니다.")
            .drive(with: self, onNext: { vc, message in
                vc.alertManager.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Gesture Setup
    private func setGesture() {
        setImageGestrue()
        setupTapKeyboardDismiss()
    }
    
    private func setImageGestrue() {
        self.thumnailView.addGestureRecognizer(imageTapGesture)
        
        imageTapGesture.rx.event
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.showPhotos()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Observer Setup
    private func setObserver() {
        imageObserver
            .compactMap({ $0 })
            .asDriver(onErrorJustReturn: .defaultIProfile)
            .drive(thumnailView.rx.image)
            .disposed(by: disposeBag)
    }
}

// MARK: - 그룹 생성 및 적용
extension CreateMeetViewController {
    private func makeMeet() -> (String?, UIImage?) {
        let nickName = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let image = try? imageObserver.value()
        return (nickName, image)
    }
}

// MARK: - 이미지 선택
extension CreateMeetViewController {
    private func showPhotos() {
        photoManager.requestPhotoLibraryPermission()
    }
}

extension CreateMeetViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= 30
    }
}

extension CreateMeetViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func setupKeyboardDismissGestrue() {
        setupTapKeyboardDismiss()
    }
}

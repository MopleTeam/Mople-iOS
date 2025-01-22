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

final class CreateMeetViewController: TitleNaviViewController, View, TransformKeyboardResponsive {
    
    
    typealias Reactor = CreateMeetViewReactor
    
    var disposeBag = DisposeBag()
    
    var presentTransition: AppTransition = .init(type: .present)
    var dismissTransition: AppTransition = .init(type: .dismiss)
    
    // MARK: - Handle KeyboardEvent
    var adjustableView: UIView { self.mainStackView }
    var floatingView: UIView { self.completionButton }
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
    
    private let imageContainerView = UIView()
    
    private let thumnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .defaultMeet
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
    
    private let textFieldView: LabeledTextFieldView = {
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
        btn.setBgColor(normalColor: ColorStyle.App.primary,
                       disabledColor: ColorStyle.Primary.disable)
        btn.setRadius(8)
        return btn
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainerView, textFieldView])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    init(title: String?,
         reactor: CreateMeetViewReactor) {
        super.init(title: title)
        self.reactor = reactor
        setupTransition()
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
        self.view.addSubview(mainStackView)
        self.view.addSubview(completionButton)
        self.imageContainerView.addSubview(thumnailView)
        self.imageContainerView.addSubview(imageEditIcon)

        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview().inset(20)
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
        
        completionButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(56)
            floatingViewBottom = make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                .inset(UIScreen.getDefatulBottomInset()).constraint
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    // MARK: - Binding
    func bind(reactor: CreateMeetViewReactor) {
        self.completionButton.rx.controlEvent(.touchUpInside)
            .compactMap({ [weak self] in self?.makeMeet() })
            .map { Reactor.Action.requestMeetCreate(group: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        naviBar.leftItemEvent
            .map { Reactor.Action.endProcess }
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
        setupKeyboardDismissGestrue()
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
            .map({ $0 ?? .defaultMeet })
            .asDriver(onErrorJustReturn: .defaultMeet)
            .drive(self.thumnailView.rx.image)
            .disposed(by: disposeBag)
        
        completionButton.rx.controlEvent(.touchUpInside)
            .map({ _ in true })
            .asDriver(onErrorJustReturn: true)
            .drive(self.textFieldView.textField.rx.isResign)
            .disposed(by: disposeBag)
        
        textFieldView.textField.rx.text
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .map({ $0.count > 1 })
            .drive(with: self, onNext: { vc, isEnabled in
                vc.completionButton.isEnabled = isEnabled
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 그룹 생성 및 적용
extension CreateMeetViewController {
    private func makeMeet() -> (String, UIImage?)? {
        guard let nickName = textFieldView.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        let image = try? imageObserver.value()
        return (nickName, image)
    }
}

// MARK: - 이미지 선택
extension CreateMeetViewController {
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

extension CreateMeetViewController: TransitionControllable {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}

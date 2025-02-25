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

final class CreateMeetViewController: TitleNaviViewController, View, TransformKeyboardResponsive, DismissTansitionControllabel {
    
    typealias Reactor = CreateMeetViewReactor
    
    var disposeBag = DisposeBag()
    
    var dismissTransition: AppTransition = .init(type: .dismiss)
    
    // MARK: - Variables
    private var hasImage: Bool = false
    private let isEditMode: Bool
    
    // MARK: - Handle KeyboardEvent
    var keyboardHeight: CGFloat?
    var keyboardHeightDiff: CGFloat?
    var overlapOffsetY: CGFloat? 
    var adjustableView: UIView { self.mainStackView }
    var floatingView: UIView { self.completionButton }
    var floatingViewBottom: Constraint?
    
    // MARK: - Manager
    private let alertManager = AlertManager.shared
   
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
        btn.setTitle(font: FontStyle.Title3.semiBold,
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
    
    init(isFlow: Bool,
         isEdit: Bool,
         title: String?,
         reactor: CreateMeetViewReactor) {
        self.isEditMode = isEdit
        super.init(title: title)
        self.reactor = reactor
        configureTransition(isNeed: !isFlow)
    }
    
    private func configureTransition(isNeed: Bool) {
        guard isNeed else { return }
        setupTransition()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
        setupKeyboardEvent()
    }
    
    private func initalSetup() {
        setupUI()
        setGesture()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
        setNaviItem()
        setTitle()
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
            make.bottom.lessThanOrEqualTo(completionButton.snp.top)
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
            floatingViewBottom = make.bottom.equalToSuperview()
                .inset(UIScreen.getBottomSafeAreaHeight()).constraint
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    private func setTitle() {
        let title = isEditMode ? "저장" : TextStyle.CreateGroup.completedTitle
        completionButton.title = title
    }

    // MARK: - Binding
    func bind(reactor: CreateMeetViewReactor) {
        naviBar.leftItemEvent
            .map { Reactor.Action.endTask }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        textFieldView.textField.rx.editText
            .compactMap({ $0 })
            .map { Reactor.Action.setNickname($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        completionButton.rx.controlEvent(.touchUpInside)
            .do(onNext: { [weak self]_ in
                self?.view.endEditing(true)
            })
            .throttle(.seconds(1),
                      latest: false,
                      scheduler: MainScheduler.instance)
            .map { Reactor.Action.createMeet }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$image)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, image in
                vc.setImage(image)
                vc.setHasImageState(image)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$canComplete)
            .asDriver(onErrorJustReturn: false)
            .drive(completionButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$previousMeet)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, meet in
                vc.setPreviousMeet(meet)
            })
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
}

// MARK: - 이미지 선택
extension CreateMeetViewController {
    private func showPhotos() {
        let defaultPhotoAction = alertManager.makeAction(title: "기본 이미지로 변경", completion: setDefaultImage)
        let selectPhotoAction = alertManager.makeAction(title: "앨범에서 사진 선택", completion: presentPhotos)
        
        if hasImage {
            alertManager.showActionSheet(actions: [selectPhotoAction, defaultPhotoAction])
        } else {
            alertManager.showActionSheet(actions: [selectPhotoAction])
        }
    }
    
    private func presentPhotos() {
        reactor?.action.onNext(.showImagePicker)
    }
    
    private func setDefaultImage() {
        reactor?.action.onNext(.resetImage)
    }
    
    private func setImage(_ image: UIImage?) {
        thumnailView.image = image ?? .defaultMeet
    }
    
    private func setHasImageState(_ image: Any?) {
        hasImage = image != nil
    }
}

// MARK: - 모임 프로필 수정
extension CreateMeetViewController {
    private func setPreviousMeet(_ meet: Meet) {
        thumnailView.kfSetimage(meet.meetSummary?.imagePath,
                                defaultImageType: .meet)
        textFieldView.text = meet.meetSummary?.name
    }
}

// MARK: - 키보드
extension CreateMeetViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func setupKeyboardDismissGestrue() {
        setupTapKeyboardDismiss()
    }
}

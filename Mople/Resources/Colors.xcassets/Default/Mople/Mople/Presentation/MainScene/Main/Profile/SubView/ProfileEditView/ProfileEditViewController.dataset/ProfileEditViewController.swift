//
//  ProfileEditViewController.swift
//  Group
//
//  Created by CatSlave on 10/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

class ProfileEditViewController: TitleNaviViewController, View, DismissTansitionControllabel, KeyboardDismissable {
    
    // MARK: - Reactor
    typealias Reactor = ProfileEditViewReactor
    var disposeBag = DisposeBag()

    // MARK: - Transition
    var dismissTransition: AppTransition = .init(type: .dismiss)
    
    // MARK: - Variables
    private var hasImage: Bool = false

    // MARK: - UI Components
    private let profileSetupView = ProfileSetupView(type: .update)

    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         editProfileReactor: ProfileEditViewReactor) {
        super.init(screenName: screenName,
                   title: title)
        self.reactor = editProfileReactor
        setupTransition()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAction()
        setupTapKeyboardDismiss()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setNaviItem()
    }
    
    // MARK: - UI Setup
    private func setLayout() {
        self.view.addSubview(profileSetupView)

        profileSetupView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
                .inset(UIScreen.getDefaultBottomPadding())
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    // MARK: - Action
    private func setupAction() {
        profileSetupView.rx.imageViewTapped
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.view.endEditing(true)
                vc.showPhotos()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Setup
extension ProfileEditViewController {
 
    func bind(reactor: ProfileEditViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
    }
    
    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        naviBar.leftItemEvent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.reactor?.action.onNext(.endView)
            })
            .disposed(by: disposeBag)
        
        profileSetupView.rx.editName
            .compactMap({ $0 })
            .map { Reactor.Action.setNickname($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        profileSetupView.rx.duplicateTapped
            .map { Reactor.Action.duplicateCheck }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        profileSetupView.rx.completeTapped
            .map { Reactor.Action.complete }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$profile)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, profile in
                vc.profileSetupView.setProfile(profile)
                vc.setHasImageState(profile.imagePath)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedImage)
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, image in
                vc.profileSetupView.setImage(image)
                vc.setHasImageState(image)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$canDuplicateCheck)
            .asDriver(onErrorJustReturn: false)
            .drive(self.profileSetupView.rx.isDuplicateEnable)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$canComplete)
            .asDriver(onErrorJustReturn: false)
            .drive(self.profileSetupView.rx.isCompleteEnable)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isDuplicate)
            .asDriver(onErrorJustReturn: false)
            .drive(self.profileSetupView.rx.isDuplicate)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, err in
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Error Handling
    private func handleError(_ err: ProfileEditError) {
        switch err {
        case .unknown:
            alertManager.showDefatulErrorMessage()
        case let .failSelectPhoto(compressionPhotoError):
            alertManager.showDefaultAlert(title: compressionPhotoError.info,
                                   subTitle: compressionPhotoError.subInfo)
        }
    }
}

// MARK: - 이미지 선택
extension ProfileEditViewController {
    private func showPhotos() {
        let defaultPhotoAction = alertManager.makeAction(title: L10n.Photo.defaultImage,
                                                         completion: setDefaultImage)
        let selectPhotoAction = alertManager.makeAction(title: L10n.Photo.selectImage,
                                                        completion: presentPhotos)
        
        if hasImage {
            alertManager.showActionSheet(actions: [selectPhotoAction, defaultPhotoAction])
        } else {
            alertManager.showActionSheet(actions: [selectPhotoAction])
        }
    }
    
    private func presentPhotos() {
        self.reactor?.action.onNext(.showImagePicker)
    }
    
    private func setDefaultImage() {
        self.reactor?.action.onNext(.resetImage)
    }
    
    private func setHasImageState(_ image: Any?) {
        hasImage = image != nil
    }
}




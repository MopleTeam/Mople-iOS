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
import PhotosUI

class ProfileEditViewController: TitleNaviViewController, View, DismissTansitionControllabel {
    typealias Reactor = ProfileEditViewReactor
    
    var disposeBag = DisposeBag()

    // MARK: - Transition
    var dismissTransition: AppTransition = .init(type: .dismiss)
    
    // MARK: - Variables
    private var hasImage: Bool = false

    // MARK: - UI Components
    private let profileSetupView = ProfileSetupView(type: .update)
    
    // MARK: - Alert
    private let alertManager = AlertManager.shared

    // MARK: - LifeCycle
    init(editProfileReactor: ProfileEditViewReactor) {
        super.init(title: TextStyle.ProfileEdit.title)
        self.reactor = editProfileReactor
        setupTransition()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }
    
    private func initalSetup() {
        setLayout()
        setNaviItem()
        setupAction()
        setupKeyboardDismissGestrue()
    }
    
    // MARK: - UI Setup
    private func setLayout() {
        self.view.addSubview(profileSetupView)

        profileSetupView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
                .inset(UIScreen.getBottomSafeAreaHeight())
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }

    // MARK: - Binding
    func bind(reactor: ProfileEditViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
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
    
    private func outputBind(_ reactor: Reactor) {
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
        
        reactor.pulse(\.$message)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "오류가 발생했습니다.")
            .drive(with: self, onNext: { vc, message in
                vc.alertManager.showAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
    
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

// MARK: - 키보드 
extension ProfileEditViewController: KeyboardDismissable {
    private func setupKeyboardDismissGestrue() {
        setupTapKeyboardDismiss()
    }
}

// MARK: - 이미지 선택
extension ProfileEditViewController {
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
        self.reactor?.action.onNext(.showImagePicker)
    }
    
    private func setDefaultImage() {
        self.reactor?.action.onNext(.resetImage)
    }
    
    private func setHasImageState(_ image: Any?) {
        hasImage = image != nil
    }
}

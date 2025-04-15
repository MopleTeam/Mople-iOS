//
//  ProfileEditViewReactor.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import UIKit
import ReactorKit

protocol ProfileEditViewCoordination: NavigationCloseable { }

enum ProfileEditError: Error {
    case failSelectPhoto(CompressionPhotoError)
    case unknown(Error)
}

class ProfileEditViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case setPreviousProfile(UserInfo)
        case setNickname(String)
        case resetImage
        case duplicateCheck
        case showImagePicker
        case complete
        case endView
    }
    
    enum Mutation {
        case updateProfile(UserInfo)
        case updateImage(UIImage?)
        case updateDuplicateAvaliable(Bool)
        case updateCompleteAvaliable(Bool)
        case updateDuplicateState(Bool?)
        case updateLoadingState(Bool)
        case catchError(ProfileEditError)
    }
    
    struct State {
        @Pulse var profile: UserInfo?
        @Pulse var selectedImage: UIImage?
        @Pulse var canDuplicateCheck: Bool = false
        @Pulse var canComplete: Bool = false
        @Pulse var isDuplicate: Bool?
        @Pulse var isLoading: Bool = false
        @Pulse var error: ProfileEditError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let editProfile: EditProfile
    private let previousProfile: UserInfo
    private var profile: ProfileEditRequest?
    private var isEditImage: Bool = false
    
    // MARK: - UseCase
    private let imageUpload: ImageUpload
    private let duplicateCheck: CheckDuplicateNickname
    
    // MARK: - Photo
    private let photoService: PhotoService
    
    // MARK: - Coordinator
    private weak var coordinator: ProfileEditViewCoordination?
    
    // MARK: - LifeCycle
    init(previousProfile: UserInfo,
         editProfile: EditProfile,
         imageUpload: ImageUpload,
         validationNickname: CheckDuplicateNickname,
         photoService: PhotoService,
         coordinator: ProfileEditViewCoordination) {
        self.previousProfile = previousProfile
        self.editProfile = editProfile
        self.duplicateCheck = validationNickname
        self.photoService = photoService
        self.imageUpload = imageUpload
        self.coordinator = coordinator
        setPreviousUserInfo(previousProfile)
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Initial Setup
    private func setPreviousUserInfo(_ userInfo: UserInfo) {
        action.onNext(.setPreviousProfile(userInfo))
        profile = .init(profile: userInfo)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setPreviousProfile(profile):
            return .just(.updateProfile(profile))
        case let .setNickname(name):
            return updateNickname(name)
        case .resetImage:
            return resetImage()
        case .duplicateCheck:
            return checkNicknameDuplicate()
        case .showImagePicker:
            return updateImage()
        case .complete:
            return requestEditProfile()
        case .endView:
            return endView()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateProfile(profile):
            newState.profile = profile
        case let .updateImage(image):
            isEditImage = true
            newState.selectedImage = image
        case let .updateDuplicateAvaliable(isAvaliable):
            newState.canDuplicateCheck = isAvaliable
        case let .updateCompleteAvaliable(isAvaliable):
            newState.canComplete = isAvaliable
        case let .updateDuplicateState(isDuplicate):
            newState.isDuplicate = isDuplicate
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}

// MARK: - Data Request
extension ProfileEditViewReactor {
    
    // MARK: - 닉네임 정규식 검사 및 업데이트
    private func updateNickname(_ name: String) -> Observable<Mutation> {
        profile?.nickname = name

        return .concat([.just(.updateDuplicateState(nil)),
                        checkDuplicateAvaliable(name: name)])
    }
    
    private func checkDuplicateAvaliable(name: String) -> Observable<Mutation> {
        let isValid = Validator.checkNickname(name)
        let isChangedName = isChangedNickname(name)
        return .concat([.just(.updateDuplicateAvaliable(isValid && isChangedName)),
                        .just(.updateCompleteAvaliable(isEditImage && !isChangedName))])
    }
    
    // MARK: - 이미지 업데이트
    private func updateImage() -> Observable<Mutation> {
        return photoService.presentImagePicker()
            .asObservable()
            .map { Mutation.updateImage($0.first) }
            .concat(checkCompleteAvaliableByPhoto())
    }
    
    private func resetImage() -> Observable<Mutation> {
        self.isEditImage = true
        return Observable<Mutation>.just(.updateImage(nil))
            .concat(checkCompleteAvaliableByPhoto())
    }
    
    private func checkCompleteAvaliableByPhoto() -> Observable<Mutation> {
        let currentName = profile?.nickname
        let isChangedName = isChangedNickname(currentName)
        let isDuplicateName = currentState.isDuplicate ?? true
        return .just(.updateCompleteAvaliable(!isChangedName || !isDuplicateName))
    }
    
    // MARK: - 닉네임 변경여부
    private func isChangedNickname(_ name: String?) -> Bool {
        let previousName = previousProfile.name
        return previousName != name
    }
    
    // MARK: - 닉네임 중복검사
    private func checkNicknameDuplicate() -> Observable<Mutation> {
        print(#function, #line)
        guard let name = profile?.nickname else { return .empty() }
        let checkValidation = duplicateCheck.execute(name)
            .asObservable()
            .map { Mutation.updateDuplicateState($0)}

        return requestWithLoading(task: checkValidation)
    }
    
    // MARK: - 프로필 편집
    private func requestEditProfile() -> Observable<Mutation> {
        let editProfile = Observable.just(isEditImage)
            .flatMap { [weak self] isEdit -> Single<String?> in
                guard let self else { return .just(nil) }
                return handleEditProfileTrigger(isEdit: isEdit)
            }
            .flatMap { [weak self] imagePath -> Single<Void> in
                guard let self else { return .just(()) }
                return self.editProfile(imagePath: imagePath)
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .flatMap({ [weak self] _ -> Observable<Mutation> in
                self?.postEditProfile()
                self?.coordinator?.dismiss(completion: nil)
                return .empty()
            })
                    
        return requestWithLoading(task: editProfile)
    }
    
    private func handleEditProfileTrigger(isEdit: Bool) -> Single<String?> {
        if isEdit {
            let image = currentState.selectedImage
            return imageUpload.execute(image)
        } else {
            let previousImagePath = self.previousProfile.imagePath
            return .just(previousImagePath)
        }
    }
    
    private func editProfile(imagePath: String?) -> Single<Void> {
        guard var profile else { return .just(()) }
        profile.image = imagePath
        return self.editProfile.execute(request: profile)
    }
}

// MARK: - Notifi {
extension ProfileEditViewReactor {
    private func postEditProfile() {
        EventService.shared.post(name: .editProfile)
    }
}

// MARK: - Coordination
extension ProfileEditViewReactor {
    private func endView() -> Observable<Mutation> {
        self.coordinator?.dismiss(completion: nil)
        return .empty()
    }
}

// MARK: - Loading & Error
extension ProfileEditViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        guard let photoErr = error as? CompressionPhotoError else {
            return .catchError(.unknown(error))
        }
        return .catchError(.failSelectPhoto(photoErr))
    }
}


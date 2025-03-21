//
//  ProfileEditViewReactor.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import UIKit
import ReactorKit

protocol ProfileEditViewCoordinator: AnyObject {
    func dismiss()
    func complete()
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
        case notifyMessage(String?)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var profile: UserInfo?
        @Pulse var selectedImage: UIImage?
        @Pulse var canDuplicateCheck: Bool = false
        @Pulse var canComplete: Bool = false
        @Pulse var isDuplicate: Bool?
        @Pulse var isLoading: Bool = false
        @Pulse var message: String?
    }
    
    private let editProfile: EditProfile
    private let imageUpload: ImageUpload
    private let duplicateCheck: CheckDuplicateNickname
    private let photoService: PhotoService
    private weak var coordinator: ProfileEditViewCoordinator?
    
    private let previousProfile: UserInfo
    private var profile: ProfileEditRequest?
    private var isEditImage: Bool = false
    
    var initialState: State = State()
    
    init(previousProfile: UserInfo,
         editProfile: EditProfile,
         imageUpload: ImageUpload,
         validationNickname: CheckDuplicateNickname,
         photoService: PhotoService,
         coordinator: ProfileEditViewCoordinator) {
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
            newState.selectedImage = image
        case let .updateDuplicateAvaliable(isAvaliable):
            newState.canDuplicateCheck = isAvaliable
        case let .updateCompleteAvaliable(isAvaliable):
            newState.canComplete = isAvaliable
        case let .updateDuplicateState(isDuplicate):
            newState.isDuplicate = isDuplicate
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .notifyMessage(message):
            newState.message = message
        case let .catchError(error):
            handleError(state: &newState, error: error)
        }
        
        return newState
    }
    
    private func handleError(state: inout State, error: Error) {
        
    }
    
    private func setPreviousUserInfo(_ userInfo: UserInfo) {
        action.onNext(.setPreviousProfile(userInfo))
        profile = .init(profile: userInfo)
    }
}

extension ProfileEditViewReactor {
    
    // MARK: - 닉네임 정규식 검사 및 업데이트
    private func updateNickname(_ name: String) -> Observable<Mutation> {
        print(#function, #line)
        let resetDuplication = Observable
            .just(Mutation.updateDuplicateState(nil))
        
        let updateDuplicateAvailable = checkDuplicateAvaliable(name: name)
        
        return .concat([resetDuplication,
                        updateDuplicateAvailable])
    }
    
    private func checkDuplicateAvaliable(name: String) -> Observable<Mutation> {
        print(#function, #line)
        let isAvailableName = checkAvailableName(name)
        
        setNickname(isAvailable: isAvailableName, name: name)
        
        let isDuplicateAvailable = Observable<Mutation>.just(.updateDuplicateAvaliable(isAvailableName))
        let isCompleteAvailable = checkCompleteAvaliableByName(name)
        return .concat([isDuplicateAvailable, isCompleteAvailable])
    }
    
    private func checkAvailableName(_ name: String) -> Bool {
        let isValid = Validator.checkNickname(name)
        let isEqualsName = isEqualsToPreviousNickname(name)
        return isValid && !isEqualsName
    }
    
    private func isEqualsToPreviousNickname(_ name: String?) -> Bool {
        let previousName = previousProfile.name
        return previousName == name
    }
    
    private func setNickname(isAvailable: Bool,
                             name: String) {
        guard isAvailable else { return }
        profile?.nickname = name
    }
    
    private func checkCompleteAvaliableByName(_ name: String) -> Observable<Mutation>  {
        let isEqualsName = isEqualsToPreviousNickname(name)
        return .just(.updateCompleteAvaliable(isEditImage && isEqualsName))
    }
    
    // MARK: - 이미지 업데이트
    private func updateImage() -> Observable<Mutation> {
        return photoService.presentImagePicker()
            .asObservable()
            .do(onNext: { [weak self] _ in
                self?.isEditImage = true
            })
            .map { Mutation.updateImage($0.first) }
            .concat(checkCompleteAvaliableByPhoto())
    }
    
    private func resetImage() -> Observable<Mutation> {
        print(#function, #line)
        self.isEditImage = true
        return Observable<Mutation>.just(.updateImage(nil))
            .concat(checkCompleteAvaliableByPhoto())
    }
    
    private func checkCompleteAvaliableByPhoto() -> Observable<Mutation> {
        let currentName = profile?.nickname
        let isEqualsName = isEqualsToPreviousNickname(currentName)
        let isDuplicateName = currentState.isDuplicate ?? true
        return .just(.updateCompleteAvaliable(isEqualsName || !isDuplicateName))
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
    #warning("중복검사 이후 중복되는 경우 핸들링")
    private func requestEditProfile() -> Observable<Mutation> {
        let editProfile = Observable.just(isEditImage)
            .flatMap { [weak self] isEdit -> Single<String?> in
                guard let self else { return .never() }
                return handleEditProfileTrigger(isEdit: isEdit)
            }
            .flatMap { [weak self] imagePath -> Single<Void> in
                guard let self else { return .never() }
                return self.editProfile(imagePath: imagePath)
            }
            .asObservable()
            .flatMap({ _ in
                return Observable<Mutation>.empty()
            })
                    
        return requestWithLoading(task: editProfile)
            .observe(on: MainScheduler.instance)
            .do(afterCompleted: { [weak self] in
                self?.coordinator?.complete()
            })
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
        guard var profile else { return .never() }
        profile.image = imagePath
        return self.editProfile.execute(request: profile)
    }
}

// MARK: - Navigator
extension ProfileEditViewReactor {
    private func endView() -> Observable<Mutation> {
        self.coordinator?.dismiss()
        return .empty()
    }
}

// MARK: - Loading
extension ProfileEditViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}




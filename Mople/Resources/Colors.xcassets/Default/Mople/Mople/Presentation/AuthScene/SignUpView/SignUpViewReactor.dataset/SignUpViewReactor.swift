//
//  ProfileCreateViewReacotr.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import UIKit
import ReactorKit

protocol SignUpCoordination: AnyObject {
    func presentMainFlow()
}

enum SignUpError: Error {
    case failSelectPhoto(CompressionPhotoError)
    case unknown(Error)
}

class SignUpViewReactor: Reactor, LifeCycleLoggable {

    enum Action {
        case setNickname(String)
        case duplicateCheck
        case createNickname
        case showImagePicker
        case resetImage
        case complete
    }
    
    enum Mutation {
        case createdNickname(String)
        case updateImage(UIImage?)
        case updateDuplicateAvaliable(Bool)
        case updateValidState(Bool?)
        case updateLoadingState(Bool)
        case catchError(SignUpError)
    }
    
    struct State {
        @Pulse var creationNickname: String?
        @Pulse var profileImage: UIImage?
        @Pulse var canDuplicateCheck: Bool = false
        @Pulse var isValidNickname: Bool?
        @Pulse var isLoading: Bool = false
        @Pulse var error: SignUpError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var isLoading: Bool = false
    private var signUpModel: SignUpRequest?
    
    // MARK: - UseCase
    private let signUpUseCase: SignUp
    private let imageUploadUseCase: ImageUpload
    private let validationNickname: CheckDuplicateNickname
    private let creationNickname: CreationNickname
    private let fetchUserInfo: FetchUserInfo
    
    // MARK: - Photo
    private let photoService: PhotoService
    
    // MARK: - Coordinator
    private weak var coordinator: SignUpCoordination?
    
    // MARK: - LifeCycle
    init(signUpUseCase: SignUp,
         imageUploadUseCase: ImageUpload,
         validationNickname: CheckDuplicateNickname,
         creationNickname: CreationNickname,
         fetchUserInfo: FetchUserInfo,
         photoService: PhotoService,
         socialInfo: SocialInfo,
         coordinator: SignUpCoordination) {
        self.signUpUseCase = signUpUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.validationNickname = validationNickname
        self.creationNickname = creationNickname
        self.fetchUserInfo = fetchUserInfo
        self.photoService = photoService
        self.coordinator = coordinator
        initialSetup(socialInfo)
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Initial Setup
    private func initialSetup(_ socialInfo: SocialInfo) {
        self.signUpModel = .init(provider: socialInfo)
        self.action.onNext(.createNickname)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setNickname(name):
            return updateNickname(name)
        case .duplicateCheck:
            return nickNameValidCheck()
        case .createNickname:
            return creationNickName()
        case .showImagePicker:
            return updateImage()
        case .resetImage:
            return resetImage()
        case .complete:
            return requsetSignUp()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .updateImage(image):
            newState.profileImage = image
        case let .createdNickname(name):
            self.signUpModel?.nickname = name
            newState.creationNickname = name
        case let .updateDuplicateAvaliable(isAvaliable):
            newState.canDuplicateCheck = isAvaliable
        case let .updateValidState(isValid):
            newState.isValidNickname = isValid
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .catchError(error):
            newState.error = error
        }
        
        return newState
    }
}

// MARK: - Data Request
extension SignUpViewReactor {
    
    // MARK: - 랜덤 닉네임 생성
    private func creationNickName() -> Observable<Mutation> {
        let createNickname = creationNickname.executue()
            .share(replay: 1)
        
        let updateNickName = createNickname
            .map { Mutation.createdNickname($0) }
        
        let checkDuplicate = createNickname
            .flatMap { [weak self] nickName -> Observable<Mutation> in
                guard let self else { return .empty() }
                return checkDuplicateAvaliable(name: nickName)
            }
        
        let zipTask = Observable.zip([updateNickName, checkDuplicate])
            .flatMap { result -> Observable<Mutation> in
                return .from(result)
            }
        
        return requestWithLoading(task: zipTask)
    }
    
    // MARK: - 닉네임 정규식 검사 및 업데이트
    private func updateNickname(_ name: String) -> Observable<Mutation> {
        let resetDuplication = Observable
            .just(Mutation.updateValidState(nil))
        
        let updateDuplicateAvailable = checkDuplicateAvaliable(name: name)
        
        return .concat([resetDuplication,
                        updateDuplicateAvailable])
    }
    
    private func checkDuplicateAvaliable(name: String) -> Observable<Mutation> {
        let canCheckDuplicate = Validator.checkNickname(name)
        setNickname(isValidName: canCheckDuplicate,
                    name: name)
        return .just(.updateDuplicateAvaliable(canCheckDuplicate))
    }
    
    private func setNickname(isValidName: Bool, name: String) {
        guard isValidName else { return }
        self.signUpModel?.nickname = name
    }
    
    // MARK: - 이미지 업데이트
    private func updateImage() -> Observable<Mutation> {
        return photoService.presentImagePicker()
            .asObservable()
            .map { Mutation.updateImage($0.first) }
    }
    
    private func resetImage() -> Observable<Mutation> {
        return .just(.updateImage(nil))
    }
    
    // MARK: - 닉네임 중복검사
    private func nickNameValidCheck() -> Observable<Mutation> {
        guard let name = signUpModel?.nickname else { return .empty() }
        let checkValidation = validationNickname.execute(name)
            .map { Mutation.updateValidState($0)}

        return requestWithLoading(task: checkValidation)
    }

    // MARK: - 회원가입
    private func requsetSignUp() -> Observable<Mutation> {
        guard isLoading == false else { return .empty() }
        isLoading = true
    
        let signUp = handleImageUpload()
            .flatMap { [weak self] imagePath -> Observable<Void> in
                guard let self else { return .empty() }
                return self.signUp(imagePath)
            }
            .flatMap({ [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return self.fetchUserInfo.execute()
            })
            .observe(on: MainScheduler.instance)
            .flatMap({ [weak self] _ -> Observable<Mutation> in
                self?.coordinator?.presentMainFlow()
                return .empty()
            })
        
        return requestWithLoading(task: signUp)
            .do(onDispose: { [weak self] in
                self?.isLoading = false
            })
    }
    
    private func handleImageUpload() -> Observable<String?> {
        guard let image = currentState.profileImage else {
            return .just(nil)
        }
        
        return imageUploadUseCase.execute(image)
            .map { $0 }
    }
    
    private func signUp(_ imagePath: String?) -> Observable<Void> {
        guard var signUpModel else { return .empty() }
        signUpModel.image = imagePath
        return self.signUpUseCase.execute(request: signUpModel)
    }
}

// MARK: - Loading & Error
extension SignUpViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        let err = handleError(error)
        return .catchError(err)
    }
    
    private func handleError(_ err: Error) -> SignUpError {
        switch err {
        case let err as CompressionPhotoError:
            return .failSelectPhoto(err)
        default:
            return .unknown(err)
        }
    }
}

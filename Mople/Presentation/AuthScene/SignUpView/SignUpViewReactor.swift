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
        case notifyMessage(String?)
        case catchError(Error)
    }
    
    struct State: LoadingState {
        @Pulse var creationNickname: String?
        @Pulse var profileImage: UIImage?
        @Pulse var canDuplicateCheck: Bool = false
        @Pulse var isValidNickname: Bool?
        @Pulse var isLoading: Bool = false
        @Pulse var message: String?
    }
    
    private let signUpUseCase: SignUp
    private let imageUploadUseCase: ImageUpload
    private let validationNickname: CheckDuplicateNickname
    private let creationNickname: CreationNickname
    private let fetchUserInfo: FetchUserInfo
    private let photoService: PhotoService
    private weak var coordinator: SignUpCoordination?
    private var signUpModel: SignUpRequest?
    
    var initialState: State = State()
    
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
        initalSetup(socialInfo)
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
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
        case let .notifyMessage(message):
            newState.message = message
        case let .catchError(error):
            handleError(state: &newState, error: error)
        }
        
        return newState
    }
    
    private func handleError(state: inout State, error: Error) {
        
    }
    
    // MARK: - Intial
    private func initalSetup(_ socialInfo: SocialInfo) {
        setSocialInfo(socialInfo)
        requestCreationNickname()
    }
    
    private func setSocialInfo(_ socialInfo: SocialInfo) {
        self.signUpModel = .init(provider: socialInfo)
    }
    
    private func requestCreationNickname() {
        self.action.onNext(.createNickname)
    }
}

// MARK: - Observable
extension SignUpViewReactor {
    
    // MARK: - 랜덤 닉네임 생성
    private func creationNickName() -> Observable<Mutation> {
        print(#function, #line)
        let createNickname = creationNickname.executue()
            .asObservable()
            .compactMap({ $0 })
            .flatMap({ [weak self] name -> Observable<Mutation> in
                guard let self else { return .empty() }
                let createdNickname = Observable<Mutation>.just(.createdNickname(name))
                let validCheckName = self.checkDuplicateAvaliable(name: name)
                return Observable.concat([createdNickname, validCheckName])
            })
        
        return requestWithLoading(task: createNickname)
    }
    
    // MARK: - 닉네임 정규식 검사 및 업데이트
    private func updateNickname(_ name: String) -> Observable<Mutation> {
        print(#function, #line)
        let resetDuplication = Observable
            .just(Mutation.updateValidState(nil))
        
        let updateDuplicateAvailable = checkDuplicateAvaliable(name: name)
        
        return .concat([resetDuplication,
                        updateDuplicateAvailable])
    }
    
    private func checkDuplicateAvaliable(name: String) -> Observable<Mutation> {
        print(#function, #line)
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
        print(#function, #line)
        return photoService.presentImagePicker()
            .asObservable()
            .map { Mutation.updateImage($0.first) }
    }
    
    private func resetImage() -> Observable<Mutation> {
        print(#function, #line)
        return .just(.updateImage(nil))
    }
    
    // MARK: - 닉네임 중복검사
    private func nickNameValidCheck() -> Observable<Mutation> {
        print(#function, #line)
        guard let name = signUpModel?.nickname else { return .empty() }
        let checkValidation = validationNickname.execute(name)
            .asObservable()
            .map { Mutation.updateValidState($0)}

        return requestWithLoading(task: checkValidation)
    }

    // MARK: - 회원가입
    private func requsetSignUp() -> Observable<Mutation> {
        print(#function, #line)
        let image = currentState.profileImage

        let signUp = imageUploadUseCase.execute(image)
            .flatMap { [weak self] imagePath -> Single<Void> in
                guard let self else { return .never() }
                return self.signUp(imagePath)
            }
            .flatMap({ [weak self] _ -> Single<Void> in
                guard let self else { return .never() }
                return self.fetchUserInfo.execute()
            })
            .asObservable()
            .flatMap({ _ in Observable<Mutation>.empty() })
        
        return requestWithLoading(task: signUp) { [weak self] in
            self?.coordinator?.presentMainFlow()
        }
    }
    
    private func signUp(_ imagePath: String?) -> Single<Void> {
        guard var signUpModel else { return .never() }
        signUpModel.image = imagePath
        return self.signUpUseCase.execute(request: signUpModel)
    }
}

// MARK: - Loading
extension SignUpViewReactor: LoadingReactor {
    var loadingState: LoadingState { currentState }
    
    func updateLoadingState(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchError(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}

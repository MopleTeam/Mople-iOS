//
//  GroupCreateViewReactor.swift
//  Group
//
//  Created by CatSlave on 11/18/24.
//

import UIKit
import ReactorKit

protocol MeetCreateViewCoordination: NavigationCloseable {
    func completed(with meet: Meet)
}

enum MeetCreationType {
    case create
    case edit(Meet)
}

enum CreateMeetError: Error {
    case unknown(Error)
    case failSelectPhoto(CompressionPhotoError)
}

final class CreateMeetViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case setNickname(String)
        case showImagePicker
        case resetImage
        case createMeet
        case setPreviousMeet(Meet)
        case endView
    }
    
    enum Mutation {
        case updateImage(UIImage?)
        case updateCompleteAvaliable(Bool)
        case updateLoadingState(Bool)
        case updatePreviousMeet(Meet)
        case catchError(CreateMeetError)
    }
    
    struct State {
        @Pulse var image: UIImage?
        @Pulse var canComplete: Bool = false
        @Pulse var previousMeet: Meet?
        @Pulse var error: CreateMeetError?
        @Pulse var isLoading: Bool = false
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var createRequest: CreateMeetRequest?
    private var isLoading: Bool = false
    private var type: MeetCreationType
    
    // MARK: - UseCase
    private let createMeetUseCase: CreateMeet
    private let editMeetUseCase: EditMeet
    private let imageUploadUseCase: ImageUpload
    
    // MARK: - Photo
    private let photoService: PhotoService
    
    // MARK: - Coordinator
    private weak var coordinator: MeetCreateViewCoordination?
    
    // MARK: - LifeCycle
    init(type: MeetCreationType,
         createMeetUseCase: CreateMeet,
         editMeetUseCase: EditMeet,
         imageUploadUseCase: ImageUpload,
         photoService: PhotoService,
         coordinator: MeetCreateViewCoordination) {
        self.type = type
        self.createMeetUseCase = createMeetUseCase
        self.editMeetUseCase = editMeetUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.photoService = photoService
        self.coordinator = coordinator
        handleCreationType()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Initial Setup
    private func handleCreationType() {
        switch type {
        case .create:
            createRequest = CreateMeetRequest()
        case let .edit(meet):
            action.onNext(.setPreviousMeet(meet))
            createRequest = .init(name: meet.meetSummary?.name,
                                image: meet.meetSummary?.imagePath)
        }
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setNickname(name):
            return updateMeetName(name)
        case .showImagePicker:
            return updateImage()
        case .resetImage:
            return resetImage()
        case .createMeet:
            return handleCreate()
        case let .setPreviousMeet(meet):
            return .just(.updatePreviousMeet(meet))
        case .endView:
            return endTask()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateImage(image):
            newState.image = image
        case let .updateCompleteAvaliable(isAvaliable):
            newState.canComplete = isAvaliable
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .updatePreviousMeet(meet):
            newState.previousMeet = meet
        case let .catchError(error):
            newState.error = error
        }

        return newState
    }
}

// MARK: - Data Request
extension CreateMeetViewReactor {
    
    // MARK: - 미팅 이름 업데이트
    private func updateMeetName(_ name: String) -> Observable<Mutation> {
        self.createRequest?.name = name
        
        return Observable.just(name)
            .map({ [weak self] in
                guard let self else { return false }
                return handleUpdateName($0)
            })
            .map { Mutation.updateCompleteAvaliable($0) }
    }
    
    private func handleUpdateName(_ name: String) -> Bool {
        let availableCount = name.count > 1
        
        switch type {
        case .create:
            return availableCount
        case .edit:
            return isChangedNameWhenEdit() && availableCount
        }
    }
    
    private func isChangedNameWhenEdit() -> Bool {
        let previousName = currentState.previousMeet?.meetSummary?.name
        let currentName = createRequest?.name
        return previousName != currentName
    }
    
    // MARK: - 이미지 업데이트
    private func updateImage() -> Observable<Mutation> {
        return photoService.presentImagePicker()
            .asObservable()
            .map { $0.first }
            .flatMap { [weak self] image -> Observable<Mutation> in
                guard let self else { return .empty() }
                return handleUpdateImage(image)
            }
    }
    
    private func handleUpdateImage(_ image: UIImage?) -> Observable<Mutation> {
        let imageMutation = Mutation.updateImage(image)
        switch type {
        case .create:
            return .just(imageMutation)
        case .edit:
            let completeMutation = Mutation.updateCompleteAvaliable(true)
            return .of(completeMutation, imageMutation)
        }
    }
    
    private func resetImage() -> Observable<Mutation> {
        createRequest?.image = nil
        return .just(.updateImage(nil))
    }
    
    // MARK: - 미팅 생성 및 편집
    private func handleCreate() -> Observable<Mutation> {
        guard isLoading == false else { return .empty() }
        let mutation: Observable<Mutation>
        switch type {
        case .create:
            mutation = requestCreateMeet()
        case let .edit(meet):
            mutation = requestEditMeet(meet)
        }
        
        return mutation
            .do(onDispose: { [weak self] in
                self?.isLoading = false
            })
    }
    
    // MARK: - 미팅 생성
    private func requestCreateMeet() -> Observable<Mutation> {
        
        let createMeet = handleImageUpload()
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { [weak self] imagePath -> Observable<Meet> in
                guard let self,
                      var request = createRequest else { return .empty() }
                request.image = imagePath
                return createMeetUseCase.execute(requset: request)
            }
            .observe(on: MainScheduler.instance)
            .flatMap({ [weak self] meet -> Observable<Mutation> in
                guard let self else { return .empty() }
                postNewMeet(meet)
                handleCompletedTask(with: meet)
                return .empty()
            })
            
        return requestWithLoading(task: createMeet)
    }
    
    // MARK: - 미팅 편집
    private func requestEditMeet(_ meet: Meet) -> Observable<Mutation> {
        
        let editMeet = handleImageUpload()
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { [weak self] imagePath -> Observable<Meet> in
                guard let self,
                      let id = meet.meetSummary?.id,
                      var request = createRequest else { return .empty() }
                request.image = imagePath ?? createRequest?.image
                return editMeetUseCase.execute(id: id,
                                               request: request)
            }
            .observe(on: MainScheduler.instance)
            .flatMap({ [weak self] meet -> Observable<Mutation> in
                guard let self else { return .empty() }
                postNewMeet(meet)
                handleCompletedTask(with: meet)
                return .empty()
            })
        
        return requestWithLoading(task: editMeet)
    }
    
    // MARK: - 이미지 업로드
    private func handleImageUpload() -> Observable<String?> {
        guard let image = currentState.image else {
            return .just(nil)
        }
        
        return imageUploadUseCase.execute(image)
            .map { $0 }
    }

    
    // MARK: - 완료 핸들링
    private func handleCompletedTask(with meet: Meet) {
        switch type {
        case .create:
            coordinator?.completed(with: meet)
        case .edit:
            coordinator?.pop()
        }
    }
}

// MARK: - Notify
extension CreateMeetViewReactor {
    private func postNewMeet(_ meet: Meet) {
        switch type {
        case .create:
            NotificationManager.shared.postItem(.created(meet),
                                         from: self)
        case .edit:
            NotificationManager.shared.postItem(.updated(meet),
                                         from: self)
        }
    }
}


// MARK: - Coordination
extension CreateMeetViewReactor {
    private func endTask() -> Observable<Mutation> {
        switch type {
        case .create:
            coordinator?.dismiss(completion: nil)
        case .edit:
            coordinator?.pop()
        }
        return .empty()
    }
}

// MARK: - Loading & Error
extension CreateMeetViewReactor: LoadingReactor {
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

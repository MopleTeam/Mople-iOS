//
//  GroupCreateViewReactor.swift
//  Group
//
//  Created by CatSlave on 11/18/24.
//

import UIKit
import ReactorKit

enum MeetCreationType {
    case create
    case edit(Meet)
}

protocol MeetCreateViewCoordination: NavigationCloseable { }

final class CreateMeetViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case setNickname(String)
        case showImagePicker
        case resetImage
        case createMeet
        case setPreviousMeet(Meet)
        case endTask
    }
    
    enum Mutation {
        case updateImage(UIImage?)
        case updateCompleteAvaliable(Bool)
        case updateLoadingState(Bool)
        case updatePreviousMeet(Meet)
        case notifyMessage(message: String?)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var image: UIImage?
        @Pulse var canComplete: Bool = false
        @Pulse var previousMeet: Meet?
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private var type: MeetCreationType
    private let createMeetUseCase: CreateMeet
    private let editMeetUseCase: EditMeet
    private let imageUploadUseCase: ImageUpload
    private let photoService: PhotoService
    private weak var coordinator: MeetCreateViewCoordination?
    private var createRequest: CreateMeetRequest?
    
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
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setNickname(name):
            return updateMeetName(name)
        case .showImagePicker:
            return updateImage()
        case .resetImage:
            return resetImage()
        case .createMeet:
            switch type {
            case .create:
                return requestCreateMeet()
            case let .edit(meet):
                return requestEditMeet(meet)
            }
        case let .setPreviousMeet(meet):
            return .just(.updatePreviousMeet(meet))
        case .endTask:
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
        case let .notifyMessage(message):
            newState.message = message
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .updatePreviousMeet(meet):
            newState.previousMeet = meet
        case let .catchError(error):
            handleError(state: &newState,
                        error: error)
        }

        return newState
    }
    
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
    
    private func handleError(state: inout State, error: Error) {
        
    }
}

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
            .flatMap(handleUpdateImage(_:))
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
        return .just(.updateImage(nil))
    }
    
    // MARK: - 미팅 생성 및 편집
    private func requestEditMeet(_ meet: Meet) -> Observable<Mutation> {
        let selectedImage = currentState.image
        
        let createMeet = imageUploadUseCase.execute(selectedImage)
            .flatMap { [weak self] imagePath -> Single<Meet> in
                guard let self,
                      let id = meet.meetSummary?.id,
                      var request = createRequest else { return .never() }
                request.image = imagePath ?? createRequest?.image
                return editMeetUseCase.execute(id: id,
                                               request: request)
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .flatMap({ [weak self] meet -> Observable<Mutation> in
                self?.notificationNewMeet(meet)
                return .empty()
            })
        
        return requestWithLoading(task: createMeet,
                                  minimumExecutionTime: .seconds(1))
        .observe(on: MainScheduler.instance)
        .do(afterCompleted: { [weak self] in
            self?.handleCompletedTask()
        })
    }
    
    private func requestCreateMeet() -> Observable<Mutation> {
        
        let selectedImage = currentState.image

        let createMeet = imageUploadUseCase.execute(selectedImage)
            .flatMap { [weak self] imagePath -> Single<Meet> in
                guard let self,
                      var request = createRequest else { return .never() }
                request.image = imagePath
                return createMeetUseCase.execute(requset: request)
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .flatMap({ [weak self] meet -> Observable<Mutation> in
                self?.notificationNewMeet(meet)
                return .empty()
            })
            
        return requestWithLoading(task: createMeet,
                                  minimumExecutionTime: .seconds(1))
        .observe(on: MainScheduler.instance)
        .do(afterCompleted: { [weak self] in
            self?.handleCompletedTask()
        })
    }
    
    private func handleCompletedTask() {
        switch type {
        case .create:
            coordinator?.dismiss()
        case .edit:
            coordinator?.pop()
        }
    }
}

// MARK: - Flow
extension CreateMeetViewReactor {
    private func endTask() -> Observable<Mutation> {
        coordinator?.dismiss()
        return .empty()
    }
}

// MARK: - Notification
extension CreateMeetViewReactor {
    private func notificationNewMeet(_ meet: Meet) {
        switch type {
        case .create:
            EventService.shared.postItem(.created(meet),
                                         from: self)
        case .edit:
            EventService.shared.postItem(.updated(meet),
                                         from: self)
        }
    }
}

extension CreateMeetViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}

//
//  GroupCreateViewReactor.swift
//  Group
//
//  Created by CatSlave on 11/18/24.
//

import UIKit
import ReactorKit

protocol MeetCreateViewCoordination: AnyObject {
    func dismiss()
}

final class CreateMeetViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case setNickname(String)
        case showImagePicker
        case resetImage
        case createMeet
        case endTask
    }
    
    enum Mutation {
        case updateImage(UIImage?)
        case updateCompleteAvaliable(Bool)
        case updateLoadingState(Bool)
        case notifyMessage(message: String?)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var image: UIImage?
        @Pulse var canComplete: Bool = false
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private let createMeetUseCase: CreateMeet
    private let imageUploadUseCase: ImageUpload
    private let photoService: PhotoService
    private weak var coordinator: MeetCreateViewCoordination?
    private var createModel = CreateMeetRequest()
    
    init(createMeetUseCase: CreateMeet,
         imageUploadUseCase: ImageUpload,
         photoService: PhotoService,
         coordinator: MeetCreateViewCoordination) {
        self.createMeetUseCase = createMeetUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.photoService = photoService
        self.coordinator = coordinator
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
            return requestCreateMeet()
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
        case let .catchError(error):
            handleError(state: &newState,
                        error: error)
        }

        return newState
    }
    
    private func handleError(state: inout State, error: Error) {
        
    }
}

extension CreateMeetViewReactor {
    
    // MARK: - 미팅 이름 업데이트
    private func updateMeetName(_ name: String) -> Observable<Mutation> {
        self.createModel.name = name
        
        return Observable.just(name.count)
            .map { $0 > 1 }
            .map { Mutation.updateCompleteAvaliable($0) }
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
    
    // MARK: - 미팅 생성
    private func requestCreateMeet() -> Observable<Mutation> {
        
        let selectedImage = currentState.image

        let createMeet = imageUploadUseCase.execute(selectedImage)
            .flatMap { [weak self] imagePath -> Single<Meet> in
                guard let self else { return .never() }
                return self.createMeet(imagePath)
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .flatMap({ [weak self] meet -> Observable<Mutation> in
                self?.notificationNewMeet(meet)
                return .empty()
            })
            
        return requestWithLoading(task: createMeet) { [weak self] in
            guard let self else { return }
            self.coordinator?.dismiss()
        }
    }
    
    private func createMeet(_ imagePath: String?) -> Single<Meet> {
        createModel.image = imagePath
        return createMeetUseCase.execute(requset: createModel)
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
        EventService.shared.postItem(.created(meet),
                                     from: self)
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

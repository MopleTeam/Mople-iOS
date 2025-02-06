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
        case requestMeetCreate(group: (title: String, image: UIImage?))
        case endProcess
    }
    
    enum Mutation {
        case notifyMessage(message: String?)
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State: LoadingState {
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private let createMeetUseCase: CreateMeet
    private let imageUploadUseCase: ImageUpload
    private weak var coordinator: MeetCreateViewCoordination?
    
    init(createMeetUseCase: CreateMeet,
         imageUploadUseCase: ImageUpload,
         coordinator: MeetCreateViewCoordination) {
        self.createMeetUseCase = createMeetUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.coordinator = coordinator
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMeetCreate(let group):
            return self.createMeet(title: group.title, image: group.image)
        case .endProcess:
            self.coordinator?.dismiss()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
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

extension CreateMeetViewReactor: LoadingReactor {
    var loadingState: LoadingState { initialState }
    
    func updateLoadingState(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchError(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}

extension CreateMeetViewReactor {
    private func createMeet(title: String, image: UIImage?) -> Observable<Mutation> {

        let createMeet = imageUploadUseCase.execute(image)
            .flatMap { [weak self] imagePath -> Single<Meet> in
                guard let self else { return .error(AppError.unknownError)}
                return self.createMeetUseCase.execute(title: title,
                                                         imagePath: imagePath)
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
    
    private func notificationNewMeet(_ meet: Meet) {
        EventService.shared.postItem(.created(meet),
                                     from: self)
    }
}

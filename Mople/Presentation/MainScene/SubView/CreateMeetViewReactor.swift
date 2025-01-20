//
//  GroupCreateViewReactor.swift
//  Group
//
//  Created by CatSlave on 11/18/24.
//

import UIKit
import ReactorKit



final class CreateMeetViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case requestMeetCreate(group: (title: String, image: UIImage?))
        case endProcess
    }
    
    enum Mutation {
        case responseMeet
        case notifyMessage(message: String?)
        case notifyLoadingState(Bool)
    }
    
    struct State {
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private let createMeetUseCase: CreateMeet
    private let imageUploadUseCase: ImageUpload
    private weak var navigator: NavigationCloseable?
    
    init(createMeetUseCase: CreateMeet,
         imageUploadUseCase: ImageUpload,
         navigator: NavigationCloseable) {
        self.createMeetUseCase = createMeetUseCase
        self.imageUploadUseCase = imageUploadUseCase
        self.navigator = navigator
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
            self.navigator?.dismiss()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .responseMeet:
            navigator?.dismiss()
        case .notifyMessage(let message):
            newState.message = message
        case .notifyLoadingState(let isLoad):
            newState.isLoading = isLoad
        }
        
        return newState
    }
}

extension CreateMeetViewReactor {
    private func createMeet(title: String, image: UIImage?) -> Observable<Mutation> {
        let loadingEnd = Observable.just(Mutation.notifyLoadingState(false))
            .filter { [weak self] _ in self?.currentState.isLoading == true }
            
        #warning("오류 발생 시 문제 해결")
        let createMeet = imageUploadUseCase.execute(image)
            .flatMap { [weak self] imagePath -> Single<Meet> in
                guard let self else { return .error(AppError.unknownError)}
                return self.createMeetUseCase.execute(title: title,
                                                         imagePath: imagePath)
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] in self?.notificationNewMeet($0) })
            .map { _ in Mutation.responseMeet }
            .catch { err in .just(.notifyMessage(message: "오류 발생")) }
            .concat(loadingEnd)
            .share()
        
        let loading = Observable.just(Mutation.notifyLoadingState(true))
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .take(until: createMeet)
            
        return .merge([createMeet, loading])
    }
    
    private func notificationNewMeet(_ meet: Meet) {
        EventService.shared.postItem(.created(meet),
                                     from: self)
    }
}

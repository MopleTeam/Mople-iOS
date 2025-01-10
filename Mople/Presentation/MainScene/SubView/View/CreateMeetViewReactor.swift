//
//  GroupCreateViewReactor.swift
//  Group
//
//  Created by CatSlave on 11/18/24.
//

import UIKit
import ReactorKit

final class CreateMeetViewReactor: Reactor {
    
    enum Action {
        case requestMeetCreate(group: (title: String?, image: UIImage?))
        case endFlow
    }
    
    enum Mutation {
        case responseMeet
        case notifyMessage(message: String?)
        case setLoading(isLoad: Bool)
    }
    
    struct State {
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private let createMeetUseCase: CreateMeet
    private weak var coordinator: CreateMeetCoordination?
    
    init(createMeetUseCase: CreateMeet,
         coordinator: CreateMeetCoordination) {
        print(#function, #line, "LifeCycle Test GroupCreateView Reactor Created" )
        self.createMeetUseCase = createMeetUseCase
        self.coordinator = coordinator
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test GroupCreateView Reactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestMeetCreate(let group):
            return self.createMeet(title: group.title, image: group.image)
        case .endFlow:
            self.coordinator?.closeSubView(completion: nil)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .responseMeet:
            coordinator?.completedAndSwitchMeetListTap(completion: nil)
        case .notifyMessage(let message):
            newState.message = message
        case .setLoading(let isLoad):
            newState.isLoading = isLoad
        }
        
        return newState
    }
}

extension CreateMeetViewReactor {
    private func createMeet(title: String?, image: UIImage?) -> Observable<Mutation> {
        let validCheck = titleValidCheck(title: title)
        
        guard validCheck.valid else {
            return .just(.notifyMessage(message: validCheck.message))
        }
    
        let loadStart = Observable.just(Mutation.setLoading(isLoad: true))
        
        #warning("오류 발생 시 문제 해결")
        let createMeet = createMeetUseCase.createMeet(title: title!, image: image)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .map { _ in Mutation.responseMeet }
            .catch { err in .just(.notifyMessage(message: "오류 발생")) }
        
        let loadEnd = Observable.just(Mutation.setLoading(isLoad: false))
            
        return Observable.concat([loadStart,
                                  createMeet,
                                  loadEnd])
    }
    
    private func titleValidCheck(title: String?) -> (valid: Bool, message: String) {
        let valid = MeetTitleValidator.validator(title)
        
        switch valid {
        case .success:
            return (true, valid.info)
        default:
            return (false, valid.info)
        }
    }
}


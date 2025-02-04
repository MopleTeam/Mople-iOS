//
//  MeetSetupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/8/25.
//

import Foundation
import ReactorKit

protocol MeetSetupCoordination: AnyObject {
    func pop()
}

final class MeetSetupViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case setMeet(_ meet: Meet)
        case popView
    }
    
    enum Mutation {
        case updateMeet(_ meet: Meet)
        case checkHost(_ isHost: Bool)
    }
    
    struct State {
        @Pulse var meet: Meet?
        @Pulse var isHost: Bool = false
    }
    
    var initialState: State = State()
    
    private weak var coordinator: MeetSetupCoordination?
    
    init(meet: Meet,
         coordinator: MeetSetupCoordination) {
        action.onNext(.setMeet(meet))
        self.coordinator = coordinator
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setMeet(Meet):
            return self.setMeetInfo(Meet)
        case .popView:
            coordinator?.pop()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateMeet(meet):
            newState.meet = meet
        case let .checkHost(isHost):
            newState.isHost = isHost
        }
        
        return newState
    }
}

extension MeetSetupViewReactor {
    private func setMeetInfo(_ meet: Meet) -> Observable<Mutation> {
        let userID = UserInfoStorage.shared.userInfo?.id
        
        let checkHost = Observable.just(Mutation.checkHost(userID == meet.creatorId))
        let updateMeet = Observable.just(Mutation.updateMeet(meet))
        
        return Observable.concat([checkHost, updateMeet])
    }
}


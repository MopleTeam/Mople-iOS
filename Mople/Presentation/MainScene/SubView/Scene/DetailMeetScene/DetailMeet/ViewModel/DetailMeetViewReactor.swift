//
//  DetailGroupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation
import ReactorKit

final class DetailMeetViewReactor: Reactor {
    
    enum Action {
        case requestMeetInfo(id: Int)
        case switchPage(isFuture: Bool)
    }
    
    enum Mutation {
        case fetchMeetInfo(meet: Meet)
        case notifyLoadingState(_ isLoading: Bool)
    }
    
    struct State {
        @Pulse var meet: Meet?
        @Pulse var isLoading: Bool = false
        @Pulse var message: String?
    }
    
    var initialState: State = State()
    
    private let fetchMeetUseCase: FetchMeetUseCase
    private let coordinator: DetailMeetCoordination
    
    init(fetchMeetUseCase: FetchMeetUseCase,
         coordinator: DetailMeetCoordination,
         meetID: Int) {
        self.fetchMeetUseCase = fetchMeetUseCase
        self.coordinator = coordinator
        action.onNext(.requestMeetInfo(id: meetID))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .requestMeetInfo(id):
            return self.fetchMeetInfo(id: id)
        case let .switchPage(isFuture):
            coordinator.swicthPlanListPage(isFuture: isFuture)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchMeetInfo(meet):
            newState.meet = meet
        case .notifyLoadingState(let isLoad):
            newState.isLoading = isLoad
        }
        
        return newState
    }
}

extension DetailMeetViewReactor {
    private func fetchMeetInfo(id: Int) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        #warning("에러 처리")
        let updateMeet = fetchMeetUseCase.fetchMeet(meetId: id)
            .asObservable()
            .map { Mutation.fetchMeetInfo(meet: $0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  updateMeet,
                                  loadingStop])
    }
}


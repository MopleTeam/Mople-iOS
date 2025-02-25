//
//  DetailGroupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation
import ReactorKit

final class MeetDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case updateMeetInfo(id: Int)
        case switchPage(isFuture: Bool)
        case pushMeetSetupView
        case editMeet(Meet)
        case planLoading(_ isLoading: Bool)
        case reviewLoading(_ isLoading: Bool)
        case endFlow
    }
    
    enum Mutation {
        case setMeetInfo(meet: Meet)
        case notifyMeetInfoLoading(_ isLoading: Bool)
        case notifyPlanLoading(_ isLoading: Bool)
        case notifyReviewLoading(_ isLoading: Bool)
    }
    
    struct State {
        @Pulse var meet: Meet?
        @Pulse var message: String?
        @Pulse var meetInfoLoaded: Bool = false
        @Pulse var futurePlanLoaded: Bool = false
        @Pulse var pastPlanLoaded: Bool = false
    }
    
    var initialState: State = State()
    
    private let fetchMeetUseCase: FetchMeetDetail
    private weak var coordinator: MeetDetailCoordination?
    
    init(fetchMeetUseCase: FetchMeetDetail,
         coordinator: MeetDetailCoordination,
         meetID: Int) {
        self.fetchMeetUseCase = fetchMeetUseCase
        self.coordinator = coordinator
        action.onNext(.updateMeetInfo(id: meetID))
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateMeetInfo(id):
            return self.fetchMeetInfo(id: id)
        case let .switchPage(isFuture):
            coordinator?.swicthPlanListPage(isFuture: isFuture)
            return .empty()
        case let .planLoading(isLoading):
            return .just(.notifyPlanLoading(isLoading))
        case let .editMeet(meet):
            return .just(.setMeetInfo(meet: meet))
        case let .reviewLoading(isLoading):
            return .just(.notifyReviewLoading(isLoading))
        case .pushMeetSetupView:
            return pushMeetSetupView()
        case .endFlow:
            coordinator?.endFlow()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .setMeetInfo(meet):
            newState.meet = meet
        case let .notifyMeetInfoLoading(isLoading):
            newState.meetInfoLoaded = isLoading
        case let .notifyPlanLoading(isLoading):
            newState.futurePlanLoaded = isLoading
        case let .notifyReviewLoading(isLoading):
            print(#function, #line, "#33 pastPlan : \(isLoading)" )
            newState.pastPlanLoaded = isLoading
        }
        
        return newState
    }
}

extension MeetDetailViewReactor {
    private func fetchMeetInfo(id: Int) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyMeetInfoLoading(true))
        
        #warning("에러 처리")
        let updateMeet = fetchMeetUseCase.execute(meetId: id)
            .asObservable()
            .map { Mutation.setMeetInfo(meet: $0) }
        
        let loadingStop = Observable.just(Mutation.notifyMeetInfoLoading(false))
        
        return Observable.concat([loadingStart,
                                  updateMeet,
                                  loadingStop])
    }
}

extension MeetDetailViewReactor {
    private func pushMeetSetupView() -> Observable<Mutation> {
        guard let meet = currentState.meet else { return .empty() }
        coordinator?.pushMeetSetupView(meet: meet)
        return .empty()
    }
}

//
//  DetailGroupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation
import ReactorKit

final class MeetDetailViewReactor: Reactor {
    
    enum Action {
        case requestMeetInfo(id: Int)
        case switchPage(isFuture: Bool)
        case pushMeetSetupView
        case futurePlanLoading(_ isLoading: Bool)
        case pastPlanLoading(_ isLoading: Bool)
        case endFlow
    }
    
    enum Mutation {
        case fetchMeetInfo(meet: Meet)
        case notifyMeetInfoLoading(_ isLoading: Bool)
        case notifyFuturePlanLoading(_ isLoading: Bool)
        case notifyPastPlanLoading(_ isLoading: Bool)
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
        print(#function, #line, "LifeCycle Test DetailMeetViewReactor Created" )

        self.fetchMeetUseCase = fetchMeetUseCase
        self.coordinator = coordinator
        action.onNext(.requestMeetInfo(id: meetID))
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DetailMeetViewReactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .requestMeetInfo(id):
            return self.fetchMeetInfo(id: id)
        case let .switchPage(isFuture):
            coordinator?.swicthPlanListPage(isFuture: isFuture)
            return .empty()
        case let .futurePlanLoading(isLoading):
            return .just(.notifyFuturePlanLoading(isLoading))
        case let .pastPlanLoading(isLoading):
            return .just(.notifyPastPlanLoading(isLoading))
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
        case let .fetchMeetInfo(meet):
            newState.meet = meet
        case let .notifyMeetInfoLoading(isLoading):
            newState.meetInfoLoaded = isLoading
        case let .notifyFuturePlanLoading(isLoading):
            newState.futurePlanLoaded = isLoading
        case let .notifyPastPlanLoading(isLoading):
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
        let updateMeet = fetchMeetUseCase.fetchMeetDetail(meetId: id)
            .asObservable()
            .map { Mutation.fetchMeetInfo(meet: $0) }
        
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

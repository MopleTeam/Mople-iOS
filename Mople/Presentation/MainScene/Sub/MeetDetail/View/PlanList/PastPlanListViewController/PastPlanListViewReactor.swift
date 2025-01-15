//
//  PastPlanListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation
import ReactorKit

final class PastPlanListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case requestReviewList
    }
    
    enum Mutation {
        case fetchReviewList(reviews: [Review])
        case notifyLoadingState(_ isLoading: Bool)
    }
    
    struct State {
        @Pulse var reviews: [Review] = []
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    let fetchReviewUseCase: FetchReviewList
    let meedId: Int
    
    init(fetchReviewUseCase: FetchReviewList,
         meetID: Int) {
        self.fetchReviewUseCase = fetchReviewUseCase
        self.meedId = meetID
        logLifeCycle()
        action.onNext(.requestReviewList)
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestReviewList:
            return fetchReviewList()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchReviewList(reviews):
            newState.reviews = reviews
        case let .notifyLoadingState(isLoad):
            newState.isLoading = isLoad
        }
        
        return newState
    }
}

extension PastPlanListViewReactor {
    private func fetchReviewList() -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let fetchPlanList = fetchReviewUseCase.fetchReviewList(meetId: meedId)
            .map({ Mutation.fetchReviewList(reviews: $0) })
            .asObservable()
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  fetchPlanList,
                                  loadingStop])
    }
}


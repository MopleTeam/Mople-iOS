//
//  ReviewViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/6/25.
//

import ReactorKit

final class ReviewEditViewReactor: Reactor {
    
    enum Action {
        case fetchReview(id: Int)
        case endFlow
    }
    
    enum Mutation {
        case updateReviewInfo(Review)
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State: LoadingState {
        @Pulse var review: Review?
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private let reviewId: Int
    
    private let fetchReviewDetail: FetchReviewDetail
    private weak var coordiantor: ReviewEditViewCoordination?
    
    init(reviewId: Int,
         fetchReviewDetail: FetchReviewDetail,
         coordinator: ReviewEditViewCoordination) {
        self.reviewId = reviewId
        self.fetchReviewDetail = fetchReviewDetail
        action.onNext(.fetchReview(id: reviewId))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetchReview(id):
            return fetchReview(id: id)
        case .endFlow:
            coordiantor?.endFlow()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateReviewInfo(review):
            newState.review = review
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .catchError(error):
            handleError(state: &newState,
                        error: error)
        }
        
        return newState
    }
    
    private func handleError(state: inout State, error: Error) {
        
    }
}

extension ReviewEditViewReactor {
    private func fetchReview(id: Int) -> Observable<Mutation> {
        
        let fetchReview = fetchReviewDetail.execute(reviewId: id)
            .asObservable()
            .map { Mutation.updateReviewInfo($0) }
        
        return requestWithLoading(task: fetchReview)
    }
}

extension ReviewEditViewReactor: LoadingReactor {
    var loadingState: LoadingState { currentState }
    
    func updateLoadingState(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchError(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}




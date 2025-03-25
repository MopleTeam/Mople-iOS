//
//  PastPlanListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation
import ReactorKit

protocol MeetReviewListCommands: AnyObject {
    func reset()
}

final class MeetReviewListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case selectedReview(index: Int)
        case requestReviewList
        case updateReview(ReviewPayload)
    }
    
    enum Mutation {
        case fetchReviewList(reviews: [Review])
    }
    
    struct State {
        @Pulse var reviews: [Review] = []
    }
    
    var initialState: State = State()
    
    private let fetchReviewUseCase: FetchReviewList
    private weak var coordinator: MeetDetailCoordination?
    private weak var delegate: MeetDetailDelegate?
    private let meedId: Int
    
    init(fetchReviewUseCase: FetchReviewList,
         coordinator: MeetDetailCoordination,
         delegate: MeetDetailDelegate,
         meetID: Int) {
        self.fetchReviewUseCase = fetchReviewUseCase
        self.coordinator = coordinator
        self.delegate = delegate
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
        case let .selectedReview(index):
            return presentReviewDetailView(index: index)
        case let .updateReview(payload):
            return handleReviewPayload(payload)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchReviewList(reviews):
            newState.reviews = reviews.sorted(by: <)
        }
        
        return newState
    }
}

extension MeetReviewListViewReactor {
    private func fetchReviewList() -> Observable<Mutation> {
        
        let fetchPlanList = fetchReviewUseCase.execute(meetId: meedId)
            .catchAndReturn([])
            .map({ Mutation.fetchReviewList(reviews: $0) })
            .asObservable()
                
        return requestWithLoading(task: fetchPlanList)
    }
    
    private func presentReviewDetailView(index: Int) -> Observable<Mutation> {
        guard let selectedReview = currentState.reviews[safe: index],
              let reviewId = selectedReview.id else { return .empty() }
        self.coordinator?.pushPlanDetailView(postId: reviewId,
                                             type: .review)
        return .empty()
    }
}

extension MeetReviewListViewReactor: MeetReviewListCommands {
    func reset() {
        action.onNext(.requestReviewList)
    }
}

// MARK: - 리뷰 알림 수신
extension MeetReviewListViewReactor {
    private func handleReviewPayload(_ payload: ReviewPayload) -> Observable<Mutation> {
        var reviewList = currentState.reviews
        
        switch payload {
        case let .updated(plan):
            self.updateReview(&reviewList, review: plan)
        case let .deleted(id):
            self.deleteReview(&reviewList, reviewId: id)
        default:
            break
        }
        return .just(.fetchReviewList(reviews: reviewList))
    }
    
    private func updateReview(_ reviewList: inout [Review], review: Review) {
        guard let updatedIndex = reviewList.firstIndex(where: {
            $0.id == review.id
        }) else { return }
        
        reviewList[updatedIndex] = review
        reviewList.sort(by: <)
    }
    
    private func deleteReview(_ reviewList: inout [Review], reviewId: Int) {
        reviewList.removeAll { $0.id == reviewId }
    }
}

extension MeetReviewListViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
    var index: Int { 1 }
}

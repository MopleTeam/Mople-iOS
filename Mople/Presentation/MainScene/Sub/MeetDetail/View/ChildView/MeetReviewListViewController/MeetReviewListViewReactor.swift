//
//  PastPlanListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation
import Domain
import ReactorKit

protocol MeetReviewListCommands: AnyObject {
    func fetchReview()
}

final class MeetReviewListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case fetchReview
        case fetchNextReview
        case selectedReview(index: Int)
        case updateReview(ReviewPayload)
        case refresh
    }
    
    enum Mutation {
        case fetchReviewList(reviews: [Review])
        case updateTotalCount(Int)
    }
    
    struct State {
        @Pulse var reviews: [Review] = []
        @Pulse var totolPlanCount: Int = 0
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let meetId: Int
    private let isJoin: Bool
    private var isLoading = false
    private(set) var page: PageInfo?
    
    // MARK: - UseCase
    private let fetchReviewUseCase: FetchMeetReviewList
    
    // MARK: - Delegate
    private weak var delegate: MeetDetailDelegate?
    
    // MARK: - LifeCycle
    init(fetchReviewUseCase: FetchMeetReviewList,
         delegate: MeetDetailDelegate,
         meetId: Int,
         isJoin: Bool = false) {
        self.fetchReviewUseCase = fetchReviewUseCase
        self.delegate = delegate
        self.meetId = meetId
        self.isJoin = isJoin
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchReview:
            return fetchReview(isRefresh: true)
        case .fetchNextReview:
            return fetchNextPage()
        case let .selectedReview(index):
            return presentReviewDetailView(index: index)
        case let .updateReview(payload):
            return handleReviewPayload(payload)
        case .refresh:
            return refreshReviewList()
        }
    }
    
    private func shouldAction(_ action: Action) -> Bool {
        switch action {
        case .fetchReview, .fetchNextReview, .refresh:
            return !isLoading
        default:
            return true
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchReviewList(reviews):
            newState.reviews = reviews.sorted(by: >)
        case let .updateTotalCount(count):
            newState.totolPlanCount = count
        }
        
        return newState
    }
}

// MARK: - Data Requset
extension MeetReviewListViewReactor {

    /// 리뷰 리스트 불러오기 (async → Observable 브릿지)
    private func fetchReview(cursor: String? = nil,
                             isRefresh: Bool = false) -> Observable<Mutation> {
        let meetId = self.meetId
        let fetchReview = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    let result = try await self?.fetchReviewUseCase.execute(meetId: meetId, cursor: cursor)
                    guard let self, let result else {
                        observer.onCompleted()
                        return
                    }
                    self.page = result.info
                    let listMutation = self.updateReviewList(isRefresh: isRefresh, reviews: result.content)
                    observer.onNext(listMutation)
                    observer.onNext(.updateTotalCount(result.totalCount))
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }
        return requestWithLoading(task: fetchReview,
                                  defferredLoadingDelay: .milliseconds(300))
    }
    
    private func updateReviewList(isRefresh: Bool, reviews: [Review]) -> Mutation {
        var newReviews = currentState.reviews
        if isRefresh {
            newReviews = reviews
        } else {
            newReviews.append(contentsOf: reviews)
        }
        return .fetchReviewList(reviews: newReviews)
    }
    
    private func fetchNextPage() -> Observable<Mutation> {
        guard let cursor = page?.nextCursor else { return .empty() }
        return fetchReview(cursor: cursor, isRefresh: false)
    }
    
    private func refreshReviewList() -> Observable<Mutation> {
        delegate?.refresh()
        return .empty()
    }
}

// MARK: - Notify
extension MeetReviewListViewReactor {
    private func handleReviewPayload(_ payload: ReviewPayload) -> Observable<Mutation> {
        var reviewList = currentState.reviews
        var totalCount = currentState.totolPlanCount
        
        switch payload {
        case let .updated(plan):
            self.updateReview(&reviewList, review: plan)
        case let .deleted(id):
            self.deleteReview(&reviewList, reviewId: id)
            totalCount -= 1
        default:
            break
        }
        
        return .of(.fetchReviewList(reviews: reviewList),
                   .updateTotalCount(max(totalCount, 0)))
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

// MARK: - Coordination
extension MeetReviewListViewReactor {
    private func presentReviewDetailView(index: Int) -> Observable<Mutation> {
        guard let selectedReview = currentState.reviews[safe: index],
              let reviewId = selectedReview.id else { return .empty() }
        self.delegate?.selectedPlan(id: reviewId,
                                    type: .review)
        return .empty()
    }
}

// MARK: - Command
extension MeetReviewListViewReactor: MeetReviewListCommands {
    func fetchReview() {
        action.onNext(.fetchReview)
    }
}

// MARK: - Loading & Error
extension MeetReviewListViewReactor: ChildLoadingReactor {
    func updateLoadingState(isLoad: Bool) {
        isLoading = isLoad
    }
    var parent: ChildLoadingDelegate? { delegate }
    var index: Int { 1 }
}

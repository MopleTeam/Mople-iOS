//
//  PlanDetailViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import Foundation
import ReactorKit

protocol CommentListDelegate {
    func commentListLoading(_ isLoading: Bool)
    func createdComment()
}

enum PlanDetailType {
    case plan
    case review
}

final class PlanDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case loadPlanInfo(_ planId: Int)
        case loadReviewInfo(_ reviewId: Int)
        case commentLoading(_ isLoading: Bool)
        case createComment(_ comment: String)
        case notifyCommentCreation
    }
    
    enum Mutation {
        case updatePlanInfo(_ Plan: PlanInfoViewModel)
        case notifyPlanInfoLoading(_ isLoading: Bool)
        case notifyCommentLoading(_ isLoading: Bool)
        case notifyMessage(_ message: String)
        case createdComment
    }
    
    struct State {
        @Pulse var planInfo: PlanInfoViewModel?
        @Pulse var isLoading: Bool = false
        @Pulse var isCommentLoading: Bool = false
        @Pulse var message: String?
        @Pulse var createdComment: Void?
    }
    
    private let fetchPlanDetailUsecase: FetchPlanDetail
    private let fetchReviewDetailUseCase: FetchReviewDetail
    private let postId: Int
    private weak var coordinator: PlanDetailCoordination?
    private var commentListCommands: CommentListCommands?
    
    var initialState: State = State()
    
    init(type: PlanDetailType,
         postId: Int,
         fetchPlanDetailUseCase: FetchPlanDetail,
         fetchReviewDetailUseCase: FetchReviewDetail,
         coordinator: PlanDetailCoordination) {
        self.fetchPlanDetailUsecase = fetchPlanDetailUseCase
        self.fetchReviewDetailUseCase = fetchReviewDetailUseCase
        self.coordinator = coordinator
        self.postId = postId
        logLifeCycle()
        
        switch type {
        case .plan:
            action.onNext(.loadPlanInfo(postId))
        case .review:
            action.onNext(.loadReviewInfo(postId))
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .loadPlanInfo(planId):
            return fetchPlanDetail(planId)
        case let .loadReviewInfo(reviewId):
            return fetchReviewDetail(reviewId)
        case let .commentLoading(isLoad):
            return .just(.notifyCommentLoading(isLoad))
        case let .createComment(comment):
            return self.createComment(comment)
        case .notifyCommentCreation:
            return .just(.createdComment)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updatePlanInfo(info):
            newState.planInfo = info
        case .notifyPlanInfoLoading(let isLoad):
            newState.isLoading = isLoad
        case let .notifyMessage(message):
            newState.message = message
        case let .notifyCommentLoading(isLoad):
            newState.isCommentLoading = isLoad
        case .createdComment:
            newState.createdComment = ()
        }
        
        return newState
    }
}

extension PlanDetailViewReactor {
    private func fetchPlanDetail(_ planId: Int) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyPlanInfoLoading(true))
        
        let fetchPlan = fetchPlanDetailUsecase.execute(planId: planId)
            .asObservable()
            .map { Mutation.updatePlanInfo(.init(plan: $0)) }
        
        let loadingStop = Observable.just(Mutation.notifyPlanInfoLoading(false))
        
        return Observable.concat([loadingStart,
                                  fetchPlan,
                                  loadingStop])
    }
    
    private func fetchReviewDetail(_ reviewId: Int) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyPlanInfoLoading(true))
        
        let fetchReview = fetchReviewDetailUseCase.execute(reviewId: reviewId)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] in
                guard !$0.images.isEmpty else { return }
                self?.coordinator?.showPhotoView(imagePaths: ["https://picsum.photos/id/\(Int.random(in: 1...100))/200/300",
                                                              "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300",
                                                              "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300",
                                                              "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300",
                                                              "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"])
            })
            .map { Mutation.updatePlanInfo(.init(review: $0)) }
        
        let loadingStop = Observable.just(Mutation.notifyPlanInfoLoading(false))
        
        return Observable.concat([loadingStart,
                                  fetchReview,
                                  loadingStop])
    }
}

extension PlanDetailViewReactor: CommentListDelegate  {
    func createdComment() {
        action.onNext(.notifyCommentCreation)
    }

    func commentListLoading(_ isLoading: Bool) {
        action.onNext(.commentLoading(isLoading))
    }
}

extension PlanDetailViewReactor {
    public func setCommentListDelegate(_ delegate: CommentListCommands) {
        self.commentListCommands = delegate
    }
    
    private func createComment(_ comment: String) -> Observable<Mutation> {
        self.commentListCommands?.createComment(comment: comment)
        return .empty()
    }
}


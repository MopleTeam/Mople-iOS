//
//  PlanDetailViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import Foundation
import ReactorKit

protocol CommentListDelegate: AnyObject {
    func setCommentListTableOffsetY(_ offsetY: CGFloat)
    func commentListLoading(_ isLoading: Bool)
    func editComment(_ comment: String)
}

final class PlanDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum ParentCommand {
            case writeComment(_ comment: String)
            case cancleEditing
        }
        
        enum ChildEvent {
            case commentLoading(_ isLoading: Bool)
            case editComment(_ comment: String)
            case changedOffsetY(_ offsetY: CGFloat)
        }
        
        enum Flow {
            case placeDetailView
            case editPlanView
            case endFlow
        }
        
        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case flow(Flow)
        case loadPlanInfo(id: Int, type: PlanDetailType)
        case editPlan(Plan)
    }
    
    enum Mutation {
        enum ChildEvent {
            case editComment(_ text: String?)
            case changedOffsetY(_ offsetY: CGFloat)
            case commentLoading(_ isLoading: Bool)
        }
        
        case updateChildEvent(ChildEvent)
        
        case planInfoLoading(_ isLoading: Bool)
        case updatePlan(_ Plan: Plan)
        case updateReview(_ review: Review)
        case notifyMessage(_ message: String)
    }
    
    struct State {
        @Pulse var commonPlanModel: CommonPlanModel?
        @Pulse var planInfo: PlanInfoViewModel?
        @Pulse var isLoading: Bool = false
        @Pulse var isCommentLoading: Bool = false
        @Pulse var message: String?
        @Pulse var editComment: String?
        @Pulse var startOffsetY: CGFloat = .zero
    }
    
    // MARK: - Variable
    private let postId: Int
    private var plan: Plan?
    private var review: Review?
    private var placeInfo: PlaceInfo?
    
    // MARK: - UseCase
    private let fetchPlanDetailUsecase: FetchPlanDetail
    private let fetchReviewDetailUseCase: FetchReviewDetail
    
    // MARK: - Coordinator
    private weak var coordinator: PlanDetailCoordination?
    
    // MARK: - Commands
    private weak var commentListCommands: CommentListCommands?
    
    // MARK: - State
    var initialState: State = State()
    
    // MARK: - LifeCycle
    init(type: PlanDetailType,
         postId: Int,
         fetchPlanDetailUseCase: FetchPlanDetail,
         fetchReviewDetailUseCase: FetchReviewDetail,
         coordinator: PlanDetailCoordination) {
        self.fetchPlanDetailUsecase = fetchPlanDetailUseCase
        self.fetchReviewDetailUseCase = fetchReviewDetailUseCase
        self.coordinator = coordinator
        self.postId = postId
        self.action.onNext(.loadPlanInfo(id: postId,
                                         type: type))
        logLifeCycle()
    }
                            		
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .loadPlanInfo(id, type):
            return handleLoad(postId: id,
                              type: type)
        case let .parentCommand(command):
            return handleParentCommand(command)
        case let .childEvent(event):
            return handleChildAction(event)
        case let .flow(action):
            return handleFlowAction(action)
        case let .editPlan(plan):
            return .just(.updatePlan(plan))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updatePlan(plan):
            self.plan = plan
            self.placeInfo = .init(plan: plan)
            newState.planInfo = .init(plan: plan)
            newState.commonPlanModel = .init(plan: plan)
        case let .updateReview(review):
            self.review = review
            self.placeInfo = .init(review: review)
            newState.planInfo = .init(review: review)
            newState.commonPlanModel = .init(reveiw: review)
        case let .notifyMessage(message):
            newState.message = message
        case let .planInfoLoading(isLoading):
            newState.isLoading = isLoading
        case let .updateChildEvent(event):
            handleChildMutation(&newState, event)
        }
        
        return newState
    }
}

// MARK: - 액션 핸들링
extension PlanDetailViewReactor {
    private func handleLoad(postId: Int,
                            type: PlanDetailType) -> Observable<Mutation> {
        switch type {
        case .plan:
            return fetchPlanDetail(postId)
        case .review:
            return fetchReviewDetail(postId)
        }
    }
    
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case .endFlow:
            coordinator?.endFlow()
        case .editPlanView:
            coordinator?.presentPlanEditFlow(plan: plan!)
        case .placeDetailView:
            coordinator?.presentPlaceDetailView(place: placeInfo!)
        }
        
        return .empty()
    }
    
    private func handleChildAction(_ event: Action.ChildEvent) -> Observable<Mutation> {
        switch event {
        case let .commentLoading(isLoad):
            return .just(.updateChildEvent(.commentLoading(isLoad)))
        case let .editComment(comment):
            return .just(.updateChildEvent(.editComment(comment)))
        case let .changedOffsetY(offsetY):
            return .just(.updateChildEvent(.changedOffsetY(offsetY)))
        }
    }
    
    private func handleParentCommand(_ command: Action.ParentCommand) -> Observable<Mutation> {
        switch command {
        case let .writeComment(comment):
            return writeComment(comment)
        case .cancleEditing:
            return cancleEditComment()
        }
    }
}

// MARK: - 상태 핸들링
extension PlanDetailViewReactor {
    private func handleChildMutation(_ state: inout State,_ event: Mutation.ChildEvent) {
        switch event {
        case let .editComment(text):
            state.editComment = text
        case let .changedOffsetY(offsetY):
            state.startOffsetY = offsetY
        case let .commentLoading(isLoad):
            state.isCommentLoading = isLoad
        }
    }
}

// MARK: - 데이터 로드
extension PlanDetailViewReactor {
    private func fetchPlanDetail(_ planId: Int) -> Observable<Mutation> {
        let fetchPlan = fetchPlanDetailUsecase.execute(planId: planId)
            .asObservable()
            .map { Mutation.updatePlan($0) }

        return fetchWithLoading(fetchPlan)
    }
    
    private func fetchReviewDetail(_ reviewId: Int) -> Observable<Mutation> {
        let fetchReview = fetchReviewDetailUseCase.execute(reviewId: reviewId)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] in
                self?.commentListCommands?.addPhotoList($0.images)
            })
            .map { Mutation.updateReview($0) }
        
        return fetchWithLoading(fetchReview)
    }
    
    private func fetchWithLoading(_ task: Observable<Mutation>) -> Observable<Mutation> {
        let startLoad = Observable.just(Mutation.planInfoLoading(true))
        
        let endLoad = Observable.just(Mutation.planInfoLoading(false))
        
        return Observable.concat([startLoad,
                                  task,
                                  endLoad])
    }
}

// MARK: - 댓글 리액터 명령
extension PlanDetailViewReactor: CommentListDelegate  {
    
    func commentListLoading(_ isLoading: Bool) {
        action.onNext(.childEvent(.commentLoading(isLoading)))
    }
    
    func editComment(_ comment: String) {
        action.onNext(.childEvent(.editComment(comment)))
    }
    
    func setCommentListTableOffsetY(_ offsetY: CGFloat) {
        action.onNext(.childEvent(.changedOffsetY(offsetY)))
    }
}

// MARK: - 댓글 리액터 요청
extension PlanDetailViewReactor {
    public func setCommentListDelegate(_ delegate: CommentListCommands) {
        self.commentListCommands = delegate
    }
    
    private func writeComment(_ comment: String) -> Observable<Mutation> {
        Observable.just(comment)
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] comment in
                self?.commentListCommands?.writeComment(comment: comment)
            })
            .flatMap { _ in
                return Observable<Mutation>.empty()
            }
    }
    
    private func cancleEditComment() -> Observable<Mutation> {
        self.commentListCommands?.cancleEditComment()
        return .just(.updateChildEvent(.editComment(nil)))
    }
}


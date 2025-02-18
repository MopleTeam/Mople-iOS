//
//  PlanDetailViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import ReactorKit

protocol CommentListDelegate: AnyObject, ChildLoadingDelegate {
    func editComment(_ comment: String?)
    func setCommentListTableOffsetY(_ offsetY: CGFloat)
    func showPhotoBook(index: Int)
    func updateLoadingState(_ isLoading: Bool)
    func catchError(_ error: Error)
}

final class PlanDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum ParentCommand {
            case writeComment(_ comment: String)
            case cancleEditing
        }
        
        enum ChildEvent {
            case commentLoading(_ isLoading: Bool)
            case editComment(_ comment: String?)
            case changedOffsetY(_ offsetY: CGFloat)
            case catchError(Error)
        }
        
        enum Update {
            case plan(PlanPayload)
            case review
        }
        
        enum Flow {
            case memberList
            case placeDetailView
            case editPlan
            case editReview
            case endFlow
        }
        
        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case update(Update)
        case flow(Flow)
        case loadPlanInfo(type: PlanDetailType)
    }
    
    enum Mutation {
        enum ChildEvent {
            case editComment(_ text: String?)
            case changedOffsetY(_ offsetY: CGFloat)
            case commentLoading(_ isLoading: Bool)
        }
        
        case updateChildEvent(ChildEvent)
        
        case updateLoadingState(_ isLoading: Bool)
        case updatePlan(_ Plan: Plan)
        case updateReview(_ review: Review)
        case notifyMessage(_ message: String)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var commonPlanModel: PlanDetailModel?
        @Pulse var planInfo: PlanInfoViewModel?
        @Pulse var isLoading: Bool = false
        @Pulse var isCommentLoading: Bool = false
        @Pulse var editComment: String?
        @Pulse var startOffsetY: CGFloat = .zero
        @Pulse var message: String?
    }
    
    // MARK: - Variable
    private let id: Int
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
         id: Int,
         fetchPlanDetailUseCase: FetchPlanDetail,
         fetchReviewDetailUseCase: FetchReviewDetail,
         coordinator: PlanDetailCoordination) {
        self.fetchPlanDetailUsecase = fetchPlanDetailUseCase
        self.fetchReviewDetailUseCase = fetchReviewDetailUseCase
        self.coordinator = coordinator
        self.id = id
        self.action.onNext(.loadPlanInfo(type: type))
        logLifeCycle()
    }
                            		
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .loadPlanInfo(type):
            return handleLoad(type: type)
        case let .parentCommand(command):
            return handleParentCommand(command)
        case let .childEvent(event):
            return handleChildAction(event)
        case let .flow(action):
            return handleFlowAction(action)
        case let .update(action):
            return handleUpdate(action)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updatePlan(plan):
            newState.planInfo = .init(plan: plan)
            newState.commonPlanModel = .init(plan: plan)
        case let .updateReview(review):
            newState.planInfo = .init(review: review)
            newState.commonPlanModel = .init(reveiw: review)
        case let .notifyMessage(message):
            newState.message = message
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .updateChildEvent(event):
            handleChildMutation(&newState, event)
        case let .catchError(err):
            handleError(state: &newState, error: err)
        }
        
        return newState
    }
    
    private func handleError(state: inout State, error: Error) {
        
    }
}

// MARK: - 액션 핸들링
extension PlanDetailViewReactor {
    private func handleLoad(type: PlanDetailType) -> Observable<Mutation> {
        switch type {
        case .plan:
            return fetchPlanDetail()
        case .review:
            return fetchReviewDetail()
        }
    }
    
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case .memberList:
            coordinator?.pushMemberListView()
        case .placeDetailView:
            coordinator?.pushPlaceDetailView(place: placeInfo!)
        case .editPlan:
            coordinator?.presentPlanEditFlow(plan: plan!)
        case .editReview:
            coordinator?.presentReviewEditFlow(review: review!)
        case .endFlow:
            coordinator?.endFlow()
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
        case let .catchError(err):
            return .just(.catchError(err))
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
    #warning("데이터 못찾으면 뒤로가기")
    private func fetchPlanDetail() -> Observable<Mutation> {
        
        let fetchPlan = fetchPlanDetailUsecase.execute(planId: id)
            .asObservable()
            .do(onNext: { [weak self] in
                self?.plan = $0
                self?.placeInfo = .init(plan: $0)
                self?.fetchCommentList($0.id)
            })
            .map { Mutation.updatePlan($0) }

        return requestWithLoading(task: fetchPlan)
    }
    
    private func fetchReviewDetail() -> Observable<Mutation> {

        let fetchReview = fetchReviewDetailUseCase.execute(reviewId: id)
            .asObservable()
            .flatMap { [weak self] review -> Observable<Mutation> in
                guard let self else { return .empty() }
                self.review = review
                self.placeInfo = .init(review: review)
                self.fetchCommentList(review.postId)
                let fetchReview = Observable<Mutation>.just(.updateReview(review))
                let fetchPhoto = fetchReviewImages(review.images)
                return Observable.concat([fetchPhoto, fetchReview])
            }
        
        return requestWithLoading(task: fetchReview)
    }
    
    private func fetchReviewImages(_ reviewImages: [ReviewImage]) -> Observable<Mutation> {
        let imagePaths = reviewImages.compactMap { $0.path }
        let imageUrls = imagePaths.compactMap { URL(string: $0) }
        let imageObservers: [Observable<UIImage?>] = Observable.imagesTaskBuilder(imageUrls: imageUrls)
        
        if imageObservers.isEmpty == false {
            return Observable.zip(imageObservers)
                .map({ images in
                    images.compactMap { $0 }
                })
                .flatMap { [weak self] images -> Observable<Mutation> in
                    guard let self else { return .empty() }
                    self.commentListCommands?.addPhotoList(images)
                    return .empty()
                }
        } else {
            self.commentListCommands?.addPhotoList([])
            return .empty()
        }
        
    }
    
    private func fetchCommentList(_ postId: Int?) {
        guard let postId else { return }
        commentListCommands?.fetchCommentList(postId: postId)
    }
}

// MARK: - 자식 -> 부모
extension PlanDetailViewReactor: CommentListDelegate  {
    func updateLoadingState(_ isLoading: Bool) {
        action.onNext(.childEvent(.commentLoading(isLoading)))
    }
    
    func editComment(_ comment: String?) {
        action.onNext(.childEvent(.editComment(comment)))
    }
    
    func setCommentListTableOffsetY(_ offsetY: CGFloat) {
        action.onNext(.childEvent(.changedOffsetY(offsetY)))
    }
    
    func showPhotoBook(index: Int) {
        print(#function, #line)
        guard let reviewImages = review?.images,
              reviewImages.isEmpty == false else { return }
        
        let imagePaths = reviewImages.compactMap { $0.path }
        coordinator?.pushPhotoView(index: index,
                                   imagePaths: imagePaths)
    }
    
    func catchError(_ error: Error) {
        action.onNext(.childEvent(.catchError(error)))
    }
}

// MARK: - 부모 -> 자식
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
            .flatMap { _ -> Observable<Mutation> in
                return .empty()
            }
    }
    
    private func cancleEditComment() -> Observable<Mutation> {
        self.commentListCommands?.completeEditComment()
        return .just(.updateChildEvent(.editComment(nil)))
    }
}

// MARK: - 노티피케이션 수신
extension PlanDetailViewReactor {
    private func handleUpdate(_ action: Action.Update) -> Observable<Mutation> {
        switch action {
        case .plan:
            return fetchPlanDetail()
        case .review:
            return fetchReviewDetail()
        }
    }
}

extension PlanDetailViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}

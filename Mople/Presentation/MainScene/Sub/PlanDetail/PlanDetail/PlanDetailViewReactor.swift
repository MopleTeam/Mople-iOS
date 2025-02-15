//
//  PlanDetailViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import ReactorKit

protocol CommentListDelegate: AnyObject {
    func setCommentListTableOffsetY(_ offsetY: CGFloat)
    func commentListLoading(_ isLoading: Bool)
    func editComment(_ comment: String)
    func showPhotoBook(index: Int)
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
        
        enum Update {
            case plan(PlanPayload)
            case review(ReviewPayload)
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
        case loadPlanInfo(id: Int, type: PlanDetailType)
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
        @Pulse var commonPlanModel: PlanDetailModel?
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
    private func fetchPlanDetail(_ planId: Int) -> Observable<Mutation> {
        let fetchPlan = fetchPlanDetailUsecase.execute(planId: planId)
            .asObservable()
            .do(onNext: { [weak self] in
                self?.plan = $0
                self?.placeInfo = .init(plan: $0)
            })
            .map { Mutation.updatePlan($0) }

        return fetchWithLoading(fetchPlan)
    }
    
    private func fetchReviewDetail(_ reviewId: Int) -> Observable<Mutation> {
        print(#function, #line)
        let fetchReview = fetchReviewDetailUseCase.execute(reviewId: reviewId)
            .asObservable()
            .do(onNext: { [weak self] in
                self?.review = $0
                self?.placeInfo = .init(review: $0)
            })
            .flatMap { [weak self] review -> Observable<Mutation> in
                guard let self else { return .empty() }
                let fetchReview = Observable<Mutation>.just(.updateReview(review))
                let fetchPhoto = fetchReviewImages(review.imagePaths)
                return Observable.concat([fetchPhoto, fetchReview])
            }
        
        return fetchWithLoading(fetchReview)
    }
    
    private func fetchReviewImages(_ paths: [String]) -> Observable<Mutation> {
        let urlList = paths.compactMap { URL(string: $0) }
        let imageObservers: [Observable<UIImage?>] = Observable.imagesTaskBuilder(imageUrls: urlList)
        return Observable.zip(imageObservers)
            .map({ images in
                images.compactMap { $0 }
            })
            .flatMap { [weak self] images -> Observable<Mutation> in
                guard let self else { return .empty() }
                self.review?.images = images
                self.commentListCommands?.addPhotoList(images)
                return .empty()
            }
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
    
    func showPhotoBook(index: Int) {
        print(#function, #line)
        guard let photoList = review?.images,
              photoList.isEmpty == false else { return }
        coordinator?.pushPhotoView(index: index,
                                   images: photoList)
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

// MARK: - 노티피케이션 수신
extension PlanDetailViewReactor {
    private func handleUpdate(_ action: Action.Update) -> Observable<Mutation> {
        switch action {
        case let .plan(payload):
            guard case .updated(let plan) = payload else { return .empty() }
            self.plan = plan
            self.placeInfo = .init(plan: plan)
            return .just(.updatePlan(plan))
        case let .review(payload):
            guard case .updated(let review) = payload else { return .empty() }
            self.review = review
            commentListCommands?.addPhotoList(review.images)
            return .empty()
        }
    }
}

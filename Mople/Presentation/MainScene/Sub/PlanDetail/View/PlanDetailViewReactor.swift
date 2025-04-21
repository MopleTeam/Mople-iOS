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
    func reportComment()
}

enum PlanDetailError: Error {
    case noResponse(ResponseError)
    case midnight(DateTransitionError)
    case failComment
    case unknown(Error)
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
            case reportComment
            case catchError(Error)
        }

        enum Flow {
            case memberList
            case placeDetailView
            case editPost
            case endFlow
        }
        
        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case flow(Flow)
        case updatePost
        case deletePost
        case reportPost
        case fetchPlanInfo
    }
    
    enum Mutation {
        enum ChildEvent {
            case editComment(_ text: String?)
            case changedOffsetY(_ offsetY: CGFloat)
        }
        
        case updateChildEvent(ChildEvent)
        case updatePlan(_ Plan: Plan)
        case updateReview(_ review: Review)
        case completeReport
        case updateLoadingState(Bool)
        case catchError(PlanDetailError)
    }
    
    struct State {
        @Pulse var commonPlanModel: PlanDetailModel?
        @Pulse var planInfo: PlanInfoViewModel?
        @Pulse var isLoading: Bool = false
        @Pulse var editComment: String?
        @Pulse var startOffsetY: CGFloat?
        @Pulse var reported: Void?
        @Pulse var error: PlanDetailError?
    }
    
    // MARK: - Variable
    var initialState: State = State()
    private let id: Int
    private let type: PlanDetailType
    private var plan: Plan?
    private var review: Review?
    private var placeInfo: PlaceInfo?
    
    // MARK: - Plan UseCase
    private let fetchPlanDetailUsecase: FetchPlanDetail
    private let deletePlanUseCase: DeletePlan
    
    // MARK: - Review UseCase
    private let fetchReviewDetailUseCase: FetchReviewDetail
    private let deleteReviewUseCase: DeleteReview
    
    // MARK: - Report UseCase
    private let reportUseCase: ReportPost
    
    // MARK: - Coordinator
    private weak var coordinator: PlanDetailCoordination?
    
    // MARK: - Commands
    public weak var commentListCommands: CommentListCommands?
    
    // MARK: - LifeCycle
    init(type: PlanDetailType,
         id: Int,
         fetchPlanDetailUseCase: FetchPlanDetail,
         fetchReviewDetailUseCase: FetchReviewDetail,
         deletePlanUseCase: DeletePlan,
         deleteReviewUseCase: DeleteReview,
         reportUseCase: ReportPost,
         coordinator: PlanDetailCoordination) {
        self.fetchPlanDetailUsecase = fetchPlanDetailUseCase
        self.fetchReviewDetailUseCase = fetchReviewDetailUseCase
        self.deletePlanUseCase = deletePlanUseCase
        self.deleteReviewUseCase = deleteReviewUseCase
        self.reportUseCase = reportUseCase
        self.coordinator = coordinator
        self.id = id
        self.type = type
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
                        
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchPlanInfo:
            return handleLoad()
        case let .parentCommand(command):
            return handleParentCommand(command)
        case let .childEvent(event):
            return handleChildAction(event)
        case let .flow(action):
            return handleFlowAction(action)
        case .updatePost:
            return handleEditPostNotify()
        case .deletePost:
            return deletePost()
        case .reportPost:
            return reportPost()
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
            newState.commonPlanModel = .init(review: review)
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .updateChildEvent(event):
            handleChildMutation(&newState, event)
        case .completeReport:
            newState.reported = ()
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}

// MARK: - Action Handling
extension PlanDetailViewReactor {
    
    // MARK: - Flow 관리
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        guard isFlowPastSchedule(with: action) == false else {
            return .just(.catchError(.midnight(.midnightReset)))
        }
        switch action {
        case .memberList:
            handlePushMemberList()
        case .editPost:
            handlePushEditPost()
        case .placeDetailView:
            coordinator?.pushPlaceDetailView(place: placeInfo!)
        case .endFlow:
            coordinator?.endFlow()
        }
        return .empty()
    }
    
    /// 타입이 일정인 경우, 일정을 수정 또는 멤버리스트로 접근 시 과거의 일정인지 체크
    ///  - 과거 일정이라면 수정이 불가, 멤버리스트는 전환된 리뷰 Id로 진입해야하기 때문에 새로고침 필요
    private func isFlowPastSchedule(with flow: Action.Flow) -> Bool {
        guard flow == .editPost || flow == .memberList else { return false }
        return isPastSchedule()
    }
    
    private func handlePushMemberList() {
        switch type {
        case .plan:
            guard let planId = plan?.id else { return }
            coordinator?.pushMemberListView(postId: planId)
        case .review:
            guard let reviewPostId = review?.postId else { return }
            coordinator?.pushMemberListView(postId: reviewPostId)
        }
    }
    
    private func handlePushEditPost() {
        switch type {
        case .plan:
            guard let plan else { return }
            coordinator?.presentPlanEditFlow(plan: plan)
        case .review:
            guard let review else { return }
            coordinator?.presentReviewEditFlow(review: review)
        }
    }
    
    // MARK: - 자식 리액터 액션 관리
    private func handleChildAction(_ event: Action.ChildEvent) -> Observable<Mutation> {
        switch event {
        case let .commentLoading(isLoad):
            return .just(.updateLoadingState(isLoad))
        case let .editComment(comment):
            return .just(.updateChildEvent(.editComment(comment)))
        case let .changedOffsetY(offsetY):
            return .just(.updateChildEvent(.changedOffsetY(offsetY)))
        case .reportComment:
            return .just(.completeReport)
        case .catchError:
            return .just(.catchError(.failComment))
        }
    }
    
    // MARK: - 자식 리액터로 전달할 액션 관리
    private func handleParentCommand(_ command: Action.ParentCommand) -> Observable<Mutation> {
        switch command {
        case let .writeComment(comment):
            return writeComment(comment)
        case .cancleEditing:
            return cancleEditComment()
        }
    }
}

// MARK: - Mutation Handling
extension PlanDetailViewReactor {
    private func handleChildMutation(_ state: inout State,
                                     _ event: Mutation.ChildEvent) {
        switch event {
        case let .editComment(text):
            state.editComment = text
        case let .changedOffsetY(offsetY):
            state.startOffsetY = offsetY
        }
    }
}

// MARK: - Data Request
extension PlanDetailViewReactor {
    
    private func handleLoad() -> Observable<Mutation> {
        switch type {
        case .plan:
            return fetchPlanDetail()
        case .review:
            return fetchReviewDetail()
        }
    }
  
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
    
    private func fetchReviewDetail(completion: (() -> Void)? = nil) -> Observable<Mutation> {

        let fetchReview = fetchReviewDetailUseCase.execute(reviewId: id)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] review -> Observable<Mutation> in
                guard let self else { return .empty() }
                self.review = review
                self.placeInfo = .init(review: review)
                self.fetchCommentList(review.postId)
                let fetchReview = Observable<Mutation>.just(.updateReview(review))
                let fetchPhoto = fetchReviewImages(review.images)
                completion?()
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
    
    private func deletePost() -> Observable<Mutation> {
        guard isPastSchedule() == false else {
            return .just(.catchError(.midnight(.midnightReset)))
        }
        let deletePost = Observable.just(type)
            .flatMap { [weak self] type -> Single<Void> in
                guard let self else { return .just(())}
                switch type {
                case .plan:
                    return deletePlanUseCase.execute(id: id)
                case .review:
                    return deleteReviewUseCase.exectue(id: id)
                }
            }
            .asObservable()
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                self?.postDeletePlan()
                self?.coordinator?.endFlow()
                return .empty()
            }
        
        return requestWithLoading(task: deletePost)
    }
    
    private func reportPost() -> Observable<Mutation> {
        guard isPastSchedule() == false else {
            return .just(.catchError(.midnight(.midnightReset)))
        }
        let reportPost = Observable.just(type)
            .flatMap { [weak self] type -> Single<Void> in
                guard let self else { return .just(()) }
                let reportType = getReportType()
                return reportUseCase.execute(type: reportType,
                                             reason: nil)
            }
            .flatMap { Observable<Mutation>.just(.completeReport) }
        
        return requestWithLoading(task: reportPost)
    }
    
    private func getReportType() -> ReportType {
        return type == .plan ? .plan(id: id) : .review(id: id)
    }
    
    /// 일정인 경우 삭제, 수정 요청하기 전 리뷰로 전환되지는 않았는지 체크
    private func isPastSchedule() -> Bool {
        guard type == .plan,
              let planDate = plan?.date else { return false }
        return DateManager.isPastDay(on: planDate)
    }
}

// MARK: - Notify
extension PlanDetailViewReactor {
    
    private func postDeletePlan() {
        switch type {
        case .plan:
            EventService.shared.postItem(PlanPayload.deleted(id: id),
                                         from: self)
        case .review:
            EventService.shared.postItem(ReviewPayload.deleted(id: id),
                                         from: self)
        }
    }
    
    private func handleEditPostNotify() -> Observable<Mutation> {
        switch type {
        case .plan:
            return updatePlan()
        case .review:
            return updateReview()
        }
    }
    
    private func updatePlan() -> Observable<Mutation> {
        return fetchPlanDetail()
    }
    
    private func updateReview() -> Observable<Mutation> {
        return fetchReviewDetail(completion: { [weak self] in
            guard let self,
                  let review = self.review else { return }
            EventService.shared.postItem(.updated(review), from: self)
        })
    }
}

// MARK: - Delegate
extension PlanDetailViewReactor: CommentListDelegate  {
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
    
    func reportComment() {
        action.onNext(.childEvent(.reportComment))
    }
}

// MARK: - Command
extension PlanDetailViewReactor {
    private func fetchCommentList(_ postId: Int?) {
        guard let postId else { return }
        commentListCommands?.fetchComment(postId: postId)
    }
    
    private func writeComment(_ comment: String) -> Observable<Mutation> {
        self.commentListCommands?.writeComment(comment: comment)
        return .empty()
    }
    
    private func cancleEditComment() -> Observable<Mutation> {
        guard currentState.editComment != nil else { return .empty() }
        self.commentListCommands?.completeEditComment()
        return .just(.updateChildEvent(.editComment(nil)))
    }
}

// MARK: - Loading & Error
extension PlanDetailViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        guard let dataError = error as? DataRequestError,
              let responseError = handleDataRequestError(err: dataError) else {
            return .catchError(.unknown(error))
        }
        return .catchError(.noResponse(responseError))
    }
    
    private func handleDataRequestError(err: DataRequestError) -> ResponseError? {
        let responseType = getResponseType()
        return DataRequestError.resolveNoResponseError(err: err,
                                                       responseType: responseType)
    }
    
    private func getResponseType() -> ResponseType {
        return type == .plan ? .plan(id: id) : .review(id: id)
    }
}

// MARK: - Child Loading & Error
extension PlanDetailViewReactor: ChildLoadingDelegate {
    func updateLoadingState(_ isLoading: Bool, index: Int) {
        action.onNext(.childEvent(.commentLoading(isLoading)))
    }
    
    func catchError(_ error: Error, index: Int) {
        action.onNext(.childEvent(.catchError(error)))
    }
}

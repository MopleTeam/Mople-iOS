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
    func refresh()
}

enum PlanDetailError: Error {
    case noResponse(ResponseError)
    case midnight
    case failComment
    case unknown(Error)
}

final class PostDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum Post {
            case fetch
            case delete
            case report
            case refresh
            case participation
        }
        
        enum Comment {
            case writeComment(_ comment: String)
            case cancleEditing
        }

        enum Flow {
            case memberList
            case placeDetailView
            case editPost
            case endFlow
        }
        
        enum ChildEvent {
            case commentLoading(_ isLoading: Bool)
            case editComment(_ comment: String?)
            case changedOffsetY(_ offsetY: CGFloat)
            case reportComment
            case catchError(Error)
        }
        
        enum Update {
            case plan(Plan)
            case review(Review)
        }
        
        case post(Post)
        case comment(Comment)
        case update(Update)
        case childEvent(ChildEvent)
        case flow(Flow)
    }
    
    enum Mutation {
        enum ChildEvent {
            case editComment(_ text: String?)
            case changedOffsetY(_ offsetY: CGFloat)
        }
        
        case updateChildEvent(ChildEvent)
        case updatePostSummary(PostSummary)
        case completeReport
        case updateLoadingState(Bool)
        case catchError(PlanDetailError)
    }
    
    struct State {
        @Pulse var postSummary: PostSummary?
        @Pulse var isLoading: Bool = false
        @Pulse var editComment: String?
        @Pulse var startOffsetY: CGFloat?
        @Pulse var isParticipation: Bool?
        @Pulse var reported: Void?
        @Pulse var error: PlanDetailError?
    }
    
    // MARK: - Variable
    var initialState: State = State()
    private let id: Int
    private let type: PostType
    private var plan: Plan?
    private var review: Review?
    
    // MARK: - Plan UseCase
    private let fetchPlanDetailUsecase: FetchPlanDetail
    private let deletePlanUseCase: DeletePlan
    private let participationPlanUseCase: ParticipationPlan
    
    // MARK: - Review UseCase
    private let fetchReviewDetailUseCase: FetchReviewDetail
    private let deleteReviewUseCase: DeleteReview
    
    // MARK: - Report UseCase
    private let reportUseCase: ReportPost
    
    // MARK: - Coordinator
    private weak var coordinator: PostDetailCoordination?
    
    // MARK: - Commands
    public weak var commentListCommands: CommentListCommands?
    
    // MARK: - LifeCycle
    init(type: PostType,
         id: Int,
         fetchPlanDetailUseCase: FetchPlanDetail,
         fetchReviewDetailUseCase: FetchReviewDetail,
         deletePlanUseCase: DeletePlan,
         deleteReviewUseCase: DeleteReview,
         participationPlanUseCase: ParticipationPlan,
         reportUseCase: ReportPost,
         coordinator: PostDetailCoordination) {
        self.fetchPlanDetailUsecase = fetchPlanDetailUseCase
        self.fetchReviewDetailUseCase = fetchReviewDetailUseCase
        self.deletePlanUseCase = deletePlanUseCase
        self.deleteReviewUseCase = deleteReviewUseCase
        self.participationPlanUseCase = participationPlanUseCase
        self.reportUseCase = reportUseCase
        self.coordinator = coordinator
        self.id = id
        self.type = type
        initialAction()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Initial Setup
    private func initialAction() {
        action.onNext(Action.post(.fetch))
    }
                        
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .post(action):
            return handlePostAction(action)
        case let .comment(action):
            return handleCommentAction(action)
        case let .childEvent(event):
            return handleChildAction(event)
        case let .flow(action):
            return handleFlowAction(action)
        case let .update(action):
            return handlePostUpdateAction(action)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updatePostSummary(postSummary):
            newState.postSummary = postSummary
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
extension PostDetailViewReactor {
    
    // MARK: - 포스트 관련 액션
    private func handlePostAction(_ action: Action.Post) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return handlePostFetchWithLoading()
        case .delete:
            return deletePost()
        case .report:
            return reportPost()
        case .refresh:
            return handleRefresh()
        case .participation:
            return handleParticipation()
        }
    }
    
    /// 포스트가 일정인 경우 참여 핸들링
    /// - 일정이 과거인 경우 : 플로우 종료 & midnight reset
    /// - 일정이 사라진 경우 : 플로우 종료
    /// - 일정 시간이 마감된 경우 : UI 업데이트
    private func handleParticipation() -> Observable<Mutation> {
        
        guard let plan,
              let planDate = plan.date else { return .empty() }
        
        switch planDate {
        case _ where DateManager.isPastDay(on: planDate):
            return .just(.catchError(.midnight))
        case _ where planDate < Date():
            guard let postSummary = currentState.postSummary else { return .empty() }
            return .just(.updatePostSummary(postSummary))
        default:
            return requestParticipation(with: plan)
        }
    }
    
    private func requestParticipation(with plan: Plan) -> Observable<Mutation> {
        var newPlan = plan
        let currentParticipation = plan.isParticipation
        
        let requestParticipation = participationPlanUseCase
            .execute(planId: id,
                     isJoining: currentParticipation)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                self?.plan = newPlan.updateParticipants()
                self?.postParticipants(with: newPlan)
                return .just(.updatePostSummary(PlanPostSummary(plan: newPlan)))
            }
        
        return requestWithLoading(task: requestParticipation)
    }
    
    private func postParticipants(with plan: Plan) {
        guard let planId = plan.id else { return }
        let payload: NotificationManager.ParticipationPayload
        = plan.isParticipation
        ? .participating(plan)
        : .notParticipation(id: planId)
        NotificationManager.shared.postParticipating(payload,
                                                     from: self)
    }
    
    // MARK: - 포스트 업데이트 액션
    private func handlePostUpdateAction(_ action: Action.Update) -> Observable<Mutation> {
        switch action {
        case let .plan(plan):
            self.plan = plan
            return .just(.updatePostSummary(PlanPostSummary(plan: plan)))
        case let .review(review):
            self.review = review
            return fetchReveiwImagesWithLoading(review)
        }
    }
    
    // MARK: - 댓글 액션 관리
    private func handleCommentAction(_ command: Action.Comment) -> Observable<Mutation> {
        switch command {
        case let .writeComment(comment):
            return writeComment(comment)
        case .cancleEditing:
            return cancleEditComment()
        }
    }
    
    // MARK: - Flow 관련 액션
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        guard isFlowPastSchedule(with: action) == false else {
            return .just(.catchError(.midnight))
        }
        switch action {
        case .memberList:
            handlePushMemberList()
        case .editPost:
            handlePushEditPost()
        case .placeDetailView:
            guard let post = currentState.postSummary else { break }
            coordinator?.pushPlaceDetailView(place: .init(post: post))
        case .endFlow:
            coordinator?.endFlow()
        }
        return .empty()
    }
    
    /// 타입이 일정인 경우, 일정을 수정 또는 멤버리스트로 접근 시 과거의 일정인지 체크
    ///  - 과거 일정이라면 수정이 불가, 멤버리스트는 전환된 리뷰 Id로 진입해야하기 때문에 새로고침 필요
    private func isFlowPastSchedule(with flow: Action.Flow) -> Bool {
        guard flow == .editPost || flow == .memberList else { return false }
        return isPastPostWhenPlanType()
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
}

// MARK: - Mutation Handling
extension PostDetailViewReactor {
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
extension PostDetailViewReactor {
    
    /// 뷰 타입에 따라서 로딩과 함께 데이터 요청
    private func handlePostFetchWithLoading() -> Observable<Mutation> {
        switch type {
        case .plan:
            return fetchPlanDetailWithLoading()
        case .review:
            return fetchReviewDetailWithLoading()
        }
    }
    
    /// 일정 데이터 불러오기
    private func fetchPlanDetail() -> Observable<Mutation> {
        return fetchPlanDetailUsecase.execute(planId: id)
            .do(onNext: { [weak self] in
                self?.plan = $0
                self?.fetchCommentList($0.id)
            })
            .map { Mutation.updatePostSummary(PlanPostSummary(plan: $0)) }
    }
  
    /// 일정 데이터 로딩과 함께 불러오기
    private func fetchPlanDetailWithLoading() -> Observable<Mutation> {
        
        let fetchPlan = fetchPlanDetail()

        return requestWithLoading(task: fetchPlan)
    }
    
    /// 후기 데이터 불러오기
    private func fetchReviewDetail() -> Observable<Mutation> {
        return fetchReviewDetailUseCase.execute(reviewId: id)
            .do(onNext: { [weak self] in
                self?.review = $0
                self?.fetchCommentList($0.postId)
            })
            .flatMap { [weak self] review -> Observable<Mutation> in
                guard let self else { return .empty() }
                return fetchReviewImages(review)
            }
    }
    
    /// 후기 데이터 로딩과 함께 불러오기
    private func fetchReviewDetailWithLoading() -> Observable<Mutation> {

        let fetchReview = fetchReviewDetail()
            
        return requestWithLoading(task: fetchReview)
    }
    
    /// 뷰 타입에 따라서 데이터 리프레쉬
    private func handleRefresh() -> Observable<Mutation> {
        let loadMutation: Observable<Mutation>
        
        switch type {
        case .plan:
            loadMutation = fetchPlanDetail()
        case .review:
            loadMutation = fetchReviewDetail()
        }
        
        return loadMutation
            .do { [weak self] _ in
                self?.commentListCommands?.completedRefreshed()
            }
    }
    
    /// 후기 이미지 불러오기
    private func fetchReviewImages(_ review: Review) -> Observable<Mutation> {
        let reviewImages = review.images
        let imagePaths = reviewImages.compactMap { $0.path }
        let imageUrls = imagePaths.compactMap { URL(string: $0) }
        let imageObservers: [Observable<UIImage?>] = Observable.imagesTaskBuilder(imageUrls: imageUrls)
        
        if imageObservers.isEmpty == false {
            return Observable.zip(imageObservers)
                .flatMap { [weak self] images -> Observable<Mutation> in
                    guard let self else { return .empty() }
                    let images = images.compactMap { $0 }
                    self.commentListCommands?.addPhotoList(images)
                    return .just(Mutation.updatePostSummary(ReviewPostSummary(review: review)))
                }
        } else {
            self.commentListCommands?.addPhotoList([])
            return .just(Mutation.updatePostSummary(ReviewPostSummary(review: review)))
        }
    }
    
    /// 로딩과 함께 후기 이미지 불러오기
    private func fetchReveiwImagesWithLoading(_ review: Review) -> Observable<Mutation> {
        let fetchReviewImage = fetchReviewImages(review)
        
        return requestWithLoading(task: fetchReviewImage)
    }
    
    /// 포스트 삭제하기
    private func deletePost() -> Observable<Mutation> {
        guard isPastPostWhenPlanType() == false else {
            return .just(.catchError(.midnight))
        }
        let deletePost = Observable.just(type)
            .flatMap { [weak self] type -> Observable<Void> in
                guard let self else { return .empty() }
                switch type {
                case .plan:
                    return deletePlanUseCase.execute(id: id)
                case .review:
                    return deleteReviewUseCase.exectue(id: id)
                }
            }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                self?.postDeletePlan()
                self?.coordinator?.endFlow()
                return .empty()
            }
        
        return requestWithLoading(task: deletePost)
    }
    
    /// 포스트 신고하기
    private func reportPost() -> Observable<Mutation> {
        guard isPastPostWhenPlanType() == false else {
            return .just(.catchError(.midnight))
        }
        let reportPost = Observable.just(type)
            .flatMap { [weak self] type -> Observable<Void> in
                guard let self else { return .empty() }
                let reportType = getReportType()
                return reportUseCase.execute(type: reportType,
                                             reason: nil)
            }
            .map { Mutation.completeReport }
        
        return requestWithLoading(task: reportPost)
    }
    
    /// 신고 타입 핸들링
    private func getReportType() -> ReportType {
        return type == .plan ? .plan(id: id) : .review(id: id)
    }
    
    /// 일정인 경우 삭제, 수정 요청하기 전 리뷰로 전환되지는 않았는지 체크
    private func isPastPostWhenPlanType() -> Bool {
        guard type == .plan,
              let planDate = plan?.date else { return false }
        return DateManager.isPastDay(on: planDate)
    }
}

// MARK: - Notify
extension PostDetailViewReactor {
    
    private func postDeletePlan() {
        switch type {
        case .plan:
            NotificationManager.shared.postItem(PlanPayload.deleted(id: id),
                                         from: self)
        case .review:
            NotificationManager.shared.postItem(ReviewPayload.deleted(id: id),
                                         from: self)
        }
    }
}

// MARK: - Delegate
extension PostDetailViewReactor: CommentListDelegate  {

    func editComment(_ comment: String?) {
        action.onNext(.childEvent(.editComment(comment)))
    }
    
    func setCommentListTableOffsetY(_ offsetY: CGFloat) {
        action.onNext(.childEvent(.changedOffsetY(offsetY)))
    }
    
    func showPhotoBook(index: Int) {
        guard let reviewImages = review?.images,
              reviewImages.isEmpty == false else { return }
        
        let imagePaths = reviewImages.compactMap { $0.path }
        coordinator?.pushPhotoView(index: index,
                                   imagePaths: imagePaths)
    }
    
    func reportComment() {
        action.onNext(.childEvent(.reportComment))
    }
    
    func refresh() {
        action.onNext(.post(.refresh))
    }
}

// MARK: - Command
extension PostDetailViewReactor {
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
extension PostDetailViewReactor: LoadingReactor {
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
extension PostDetailViewReactor: ChildLoadingDelegate {
    func updateLoadingState(_ isLoading: Bool, index: Int) {
        action.onNext(.childEvent(.commentLoading(isLoading)))
    }
    
    func catchError(_ error: Error, index: Int) {
        action.onNext(.childEvent(.catchError(error)))
    }
}

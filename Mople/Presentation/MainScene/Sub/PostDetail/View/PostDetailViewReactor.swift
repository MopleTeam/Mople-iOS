//
//  PlanDetailViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import ReactorKit

enum PlanDetailError: Error {
    case noResponse(ResponseError)
    case midnight
    case unknown(Error)
}

final class PostDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum Post {
            case fetch
            case delete
            case refresh
            case participation
            case report
        }

        enum Flow {
            case memberList
            case placeDetailView
            case editPost
            case endFlow
            case photoView(index: Int)
        }

        enum Update {
            case plan(Plan)
            case review(Review)
        }
        
        case post(Post)
        case update(Update)
        case flow(Flow)
    }
    
    enum Mutation {
        case updatePostSummary(PostSummary)
        case completeReport
        case updateLoadingState(Bool)
        case catchError(PlanDetailError)
    }
    
    struct State {
        @Pulse var postSummary: PostSummary?
        @Pulse var reported: Void?
        @Pulse var isLoading: Bool = false
        @Pulse var error: PlanDetailError?
    }
    
    // MARK: - Variable
    var initialState: State = State()
    private let id: Int
    private(set) var meetId: Int?
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
        case .completeReport:
            newState.reported = ()
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
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
        case .refresh:
            return handleRefresh()
        case .participation:
            return handleParticipation()
        case .report:
            return reportPost()
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
                     isJoin: !currentParticipation)
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
            return .just(.updatePostSummary(ReviewPostSummary(review: review)))
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
            handleEditPost()
        case .placeDetailView:
            guard let post = currentState.postSummary else { break }
            coordinator?.pushPlaceDetailView(place: .init(post: post))
        case .photoView(let index):
            guard let imagePath = review?.images,
                  imagePath.count > index else { return .empty() }
            coordinator?.presentPhotoView(title: "함께한 순간",
                                          index: index,
                                          imagePaths: imagePath.compactMap({ $0.path }),
                                          defaultType: .history)
        case .endFlow:
            coordinator?.endFlow()
        }
        return .empty()
    }
    
    /// 타입이 일정인 경우, 일정을 수정 또는 멤버리스트로 접근 시 과거의 일정인지 체크
    ///  - 과거 일정이라면 수정이 불가, 멤버리스트는 전환된 리뷰 Id로 진입해야하기 때문에 새로고침 필요
    private func isFlowPastSchedule(with flow: Action.Flow) -> Bool {
        switch flow {
        case .editPost, .memberList: return isPastPostWhenPlanType()
        default: return false
        }
    }
    
    private func handlePushMemberList() {
        switch type {
        case .plan:
            guard let planId = plan?.id else { return }
            coordinator?.pushMemberListView(postId: planId)
        default:
            guard let reviewPostId = review?.postId else { return }
            coordinator?.pushMemberListView(postId: reviewPostId)
        }
    }
    
    private func handleEditPost() {
        switch type {
        case .plan:
            guard let plan else { return }
            coordinator?.presentPlanEditFlow(plan: plan)
        default:
            guard let review else { return }
            coordinator?.pushReviewEditView(review: review)
        }
    }
}

// MARK: - Data Request
extension PostDetailViewReactor {
    
    // MARK: - Fetch
    /// 뷰 타입에 따라서 로딩과 함께 데이터 요청
    private func handlePostFetchWithLoading() -> Observable<Mutation> {
        switch type {
        case .plan:
            return requestWithLoading(task: fetchPlan())
        case .review:
            return requestWithLoading(task: fetchReview())
        case .oldPlan:
            return requestWithLoading(task: fetchReview(isOldPlan: true))
        }
    }
    
    private func fetchPlan(isRefresh: Bool = false) -> Observable<Mutation> {
        
        return fetchPlanDetailUsecase.execute(planId: id)
            .do(onNext: { [weak self] in
                self?.plan = $0
                self?.meetId = $0.meet?.id
            })
            .map { Mutation.updatePostSummary(PlanPostSummary(plan: $0)) }
    }
    
    private func fetchReview(isRefresh: Bool = false, isOldPlan: Bool = false) -> Observable<Mutation> {

        return fetchReviewDetailUseCase.execute(id: id, isOldPlan: isOldPlan)
            .do(onNext: { [weak self] in
                self?.review = $0
                self?.meetId = $0.meet?.id
            })
            .map { Mutation.updatePostSummary(ReviewPostSummary(review: $0)) }
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
                    guard let planId = plan?.id else { return .empty() }
                    return deletePlanUseCase.execute(id: planId)
                default:
                    guard let reviewId = review?.id else { return .empty() }
                    return deleteReviewUseCase.exectue(id: reviewId)
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
        guard isPastPostWhenPlanType() == false, let type = getReportType() else {
            return .just(.catchError(.midnight))
        }
        let reportPost = reportUseCase.execute(type: type,
                                               reason: nil)
            .map { Mutation.completeReport }
        
        return requestWithLoading(task: reportPost)
    }
    
    /// 신고 타입 핸들링
    private func getReportType() -> ReportType? {
        switch type {
        case .plan:
            guard let planId = plan?.id else { return nil }
            return .plan(id: planId)
        default:
            guard let reviewId = review?.id else { return nil }
            return .review(id: reviewId)
        }
    }
    
    /// 일정인 경우 삭제, 수정 요청하기 전 리뷰로 전환되지는 않았는지 체크
    private func isPastPostWhenPlanType() -> Bool {
        guard type == .plan,
              let planDate = plan?.date else { return false }
        return DateManager.isPastDay(on: planDate)
    }
    
    // MARK: - Refresh
    /// 뷰 타입에 따라서 데이터 리프레쉬
    private func handleRefresh() -> Observable<Mutation> {
        let loadMutation: Observable<Mutation>
        
        switch type {
        case .plan:
            loadMutation = fetchPlan(isRefresh: true)
        default:
            loadMutation = fetchReview(isRefresh: true)
        }
        
        return loadMutation
    }
}

// MARK: - Notify
extension PostDetailViewReactor {
    
    private func postDeletePlan() {
        switch type {
        case .plan:
            guard let planId = plan?.id else { return }
            NotificationManager.shared.postItem(PlanPayload.deleted(id: id),
                                         from: self)
        default:
            guard let reviewId = review?.id else { return }
            NotificationManager.shared.postItem(ReviewPayload.deleted(id: reviewId),
                                         from: self)
        }
    }
}

// MARK: - Loading & Error
extension PostDetailViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        guard let dataError = error as? DataRequestError,
              let responseError = resolveDataRequestError(err: dataError) else {
            return .catchError(.unknown(error))
        }
        return .catchError(.noResponse(responseError))
    }
    
    private func resolveDataRequestError(err: DataRequestError) -> ResponseError? {
        let responseType = getResponseType()
        return DataRequestError.resolveNoResponseError(err: err,
                                                       responseType: responseType)
    }
    
    private func getResponseType() -> ResponseType {
        return type == .plan ? .plan(id: id) : .review(id: id)
    }
}


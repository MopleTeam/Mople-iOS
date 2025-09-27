//
//  PlanDetailSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import RxSwift

protocol PostDetailSceneDependencies {
    // MARK: - 기본 뷰
    func makePlanDetailViewController(coordinator: PostCoordination) -> PostDetailViewController
    
    // MARK: - 이동 뷰
    func makePlaceDetailViewController(place: PlaceInfo,
                                       coordinator: PlaceDetailCoordination) -> PlaceDetailViewController
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController
    func makePhotoBookViewController(title: String?,
                                     imagePaths: [String],
                                     defaultType: UIImageView.DefaultImageType) -> PhotoBookViewController
    
    func makeReviewEditViewController(review: Review,
                                      coordinator: ReviewEditViewCoordination) -> ReviewEditViewController

    func makeCommentListViewController(type: CommentListType,
                                       coordinator: CommentListCoordination) -> CommentListViewController
    // MARK: - 이동 플로우
    func makePlanEditFlowCoordiantor(plan: Plan) -> BaseCoordinator
}

final class PostDetailSceneDIContainer: BaseContainer, PostDetailSceneDependencies {
    
    private let postType: PostType
    private let postId: Int
    
    init(appNetworkService: AppNetworkService,
         commonFactory: ViewDependencies,
         type: PostType,
         postId: Int) {
        self.postType = type
        self.postId = postId
        super.init(appNetworkService: appNetworkService,
                   commonFactory: commonFactory)
    }
    
    func makePostDetailCoordinator() -> PostDetailFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
    }
}

// MARK: - Default View
extension PostDetailSceneDIContainer {
    
    // MARK: - 포스트 상세
    func makePlanDetailViewController(coordinator: PostCoordination) -> PostDetailViewController {
        let screenName: ScreenName = postType == .plan ? .plan_detail : .review_detail
        let title = postType == .plan ? L10n.Postdetail.plan : L10n.Postdetail.review
        return .init(screenName: screenName,
                     title: title,
                     postType: postType,
                     reactor: makePostDetailViewReactor(type: postType,
                                                        coordinator: coordinator),
                     commentVC: makeCommentListViewController(type: .parent,
                                                              coordinator: coordinator))
    }
    
    private func makePostDetailViewReactor(type: PostType,
                                           coordinator: PostDetailCoordination) -> PostDetailViewReactor {
        let planRepo = DefaultPlanRepo(networkService: appNetworkService)
        let reviewRepo = DefaultReviewRepo(networkService: appNetworkService)
        return .init(type: type,
                     id: postId,
                     fetchPlanDetailUseCase: makeFetchPlanDetailUsecase(repo: planRepo),
                     fetchReviewDetailUseCase: makeFetchReviewDetailUseCase(repo: reviewRepo),
                     deletePlanUseCase: makeDeletePlanUseCase(repo: planRepo),
                     deleteReviewUseCase: makeDeleteReviewUseCase(repo: reviewRepo),
                     participationPlanUseCase: makeParticipationPlanUseCase(repo: planRepo),
                     reportUseCase: makeReportUseCase(),
                     coordinator: coordinator)
    }
    
    
    private func makeFetchPlanDetailUsecase(repo: PlanRepo) -> FetchPlanDetail {
        return FetchPlanDetailUseCase(repo: repo)
    }
    
    private func makeDeletePlanUseCase(repo: PlanRepo) -> DeletePlan {
        return DeletePlanUseCase(repo: repo)
    }
    
    private func makeParticipationPlanUseCase(repo: PlanRepo) -> ParticipationPlan {
        return ParticipationPlanUseCase(participationRepo: repo)
    }
    
    private func makeFetchReviewDetailUseCase(repo: ReviewRepo) -> FetchReviewDetail {
        return FetchReviewDetailUseCase(repo: repo)
    }
    
    private func makeDeleteReviewUseCase(repo: ReviewRepo) -> DeleteReview {
        return DeleteReviewUseCase(repo: repo)
    }

    // MARK: - 댓글뷰
    func makeCommentListViewController(type: CommentListType,
                                       coordinator: CommentListCoordination) -> CommentListViewController {
        let commentReactor = makeCommentListViewReactor(type: type,
                                                        reportUseCase: makeReportUseCase(),
                                                        coordinator: coordinator)
        return .init(reactor: commentReactor,
                     mentionVC: makeMentionListViewController())
    }
    
    private func makeCommentListViewReactor(type: CommentListType,
                                            reportUseCase: ReportPost,
                                            coordinator: CommentListCoordination) -> CommentListViewReactor {
        let commentRepo = makeCommentRepo()
        
        return .init(type: type,
                     fetchCommentListUseCase: makeFetchCommentListUseCase(repo: commentRepo),
                     fetchReplyCommentListUseCase: makeFetchReplyCommentListUseCase(repo: commentRepo),
                     createCommentUseCase: makeCreateCommentUseCase(repo: commentRepo),
                     createReplyUseCase: makeCreateReplyUseCase(repo: commentRepo),
                     deleteCommentUseCase: makeDeleteCommentUseCase(repo: commentRepo),
                     editCommentUseCase: makeEditCommentUseCase(repo: commentRepo),
                     reportUseCase: reportUseCase,
                     likeCommentUseCase: makeLikeCommentUseCase(repo: commentRepo),
                     coordinator: coordinator)
    }
    
    private func makeCommentRepo() -> CommentRepo {
        return DefaultCommentRepo(networkService: appNetworkService)
    }
    
    // 댓글 UseCase
    private func makeFetchCommentListUseCase(repo: CommentRepo) -> FetchCommentList {
        return FetchCommentListUseCase(repo: repo)
    }
    
    private func makeCreateCommentUseCase(repo: CommentRepo) -> CreateComment {
        return CreateCommentUseCase(repo: repo)
    }
    
    // 대댓글 UseCase
    private func makeFetchReplyCommentListUseCase(repo: CommentRepo) -> FetchReplyCommentList {
        return FetchReplyCommentListUseCase(repo: repo)
    }
    
    private func makeCreateReplyUseCase(repo: CommentRepo) -> CreateReplyComment {
        return CreateReplyCommentUseCase(repo: repo)
    }
    
    // 공통
    private func makeDeleteCommentUseCase(repo: CommentRepo) -> DeleteComment {
        return DeleteCommentUseCase(repo: repo)
    }
    
    private func makeEditCommentUseCase(repo: CommentRepo) -> EditComment {
        return EditCommentUseCase(repo: repo)
    }
    
    private func makeLikeCommentUseCase(repo: CommentRepo) -> LikeComment {
        return LikeCommentUseCase(repo: repo)
    }
    
    // MARK: - 신고 유즈케이스
    private func makeReportUseCase() -> ReportPost {
        let repo = DefaultReportRepo(networkService: appNetworkService)
        return ReportPostUseCase(repo: repo)
    }
    
    // MARK: - 멘션뷰
    private func makeMentionListViewController() -> MentionListViewController {
        return .init(reactor: makeMentionListReactor())
    }
    
    private func makeMentionListReactor() -> MentionListViewReactor {
        return .init(fetchMentionListUseCase: makeFetchMentionListUseCase())
    }
    
    private func makeFetchMentionListUseCase() -> FetchMentionList {
        return FetchMentionListUseCase(repo: DefaultMentionRepo(networkService: appNetworkService))
    }
}

// MARK: - View
extension PostDetailSceneDIContainer {
    
    // MARK: - 상세 지도
    func makePlaceDetailViewController(place: PlaceInfo,
                                       coordinator: PlaceDetailCoordination) -> PlaceDetailViewController {
        return PlaceDetailViewController(screenName: .map_detail,
                                         title: L10n.placedetail,
                                         reactor: makePlaceDetailViewReactor(place: place,
                                                                             coordinator: coordinator))
    }
    
    private func makePlaceDetailViewReactor(place: PlaceInfo, coordinator: PlaceDetailCoordination) -> PlaceDetailViewReactor {
        return PlaceDetailViewReactor(place: place,
                                  locationService: DefaultLocationService(),
                                  coordinator: coordinator)
    }
    
    // MARK: - 멤버 리스트
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController {
        return commonViewFactory.makeMemberListViewController(type: getMemberListType(),
                                                          coordinator: coordinator)
    }
    
    private func getMemberListType() -> MemberListType {
        if case .plan = postType {
            return .plan(id: postId)
        } else {
            return .review(id: postId)
        }
    }
    
    // MARK: - 리뷰 편집
    func makeReviewEditViewController(review: Review,
                                       coordinator: ReviewEditViewCoordination) -> ReviewEditViewController {
        let title = review.isReviewd ? L10n.Review.edit : L10n.Review.create
        return .init(screenName: .review_write,
                     title: title,
                     reactor: makePlanDetailViewReactor(review: review,
                                                        coordinator: coordinator))
    }
    
    private func makePlanDetailViewReactor(review: Review,
                                           coordinator: ReviewEditViewCoordination) -> ReviewEditViewReactor {
        let reviewRepo = DefaultReviewRepo(networkService: appNetworkService)
        let imageRepo = DefaultImageUploadRepo(networkService: appNetworkService)
        return .init(review: review,
                     fetchReview: makeFetchReviewUseCase(repo: reviewRepo),
                     deleteReviewImage: makeDeleteReviewUseCase(repo: reviewRepo),
                     imageUpload: makeReviewImageUploadUseCase(repo: imageRepo),
                     photoService: DefaultPhotoService(),
                     coordinator: coordinator)
    }
    
    private func makeFetchReviewUseCase(repo: ReviewRepo) -> FetchReviewDetail {
        return FetchReviewDetailUseCase(repo: repo)
    }
    
    private func makeDeleteReviewUseCase(repo: ReviewRepo) -> DeleteReviewImage {
        return DeleteReviewImageUseCase(repo: repo)
    }
    
    private func makeReviewImageUploadUseCase(repo: ImageUploadRepo) -> ReviewImageUpload {
        return ReviewImageUploadUseCase(repo: repo)
    }
    
    // MARK: - 포토북
    func makePhotoBookViewController(title: String?,
                                     imagePaths: [String],
                                     defaultType: UIImageView.DefaultImageType) -> PhotoBookViewController {
        return commonViewFactory.makePhotoViewController(title: title,
                                                         imagePath: imagePaths,
                                                         defaultImageType: defaultType)
    }
}

// MARK: - Flow
extension PostDetailSceneDIContainer {
    
    // MARK: - 일정 편집
    func makePlanEditFlowCoordiantor(plan: Plan) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            commonViewFactory: commonViewFactory,
            type: .edit(plan))
        return planCreateDI.makePlanCreateFlowCoordinator()
    }
}


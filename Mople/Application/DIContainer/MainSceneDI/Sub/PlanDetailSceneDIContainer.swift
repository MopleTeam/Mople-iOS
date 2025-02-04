//
//  PlanDetailSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import RxSwift

protocol PlanDetailSceneDependencies {
    // MARK: - 기본 뷰
    func makePlanDetailViewController(type: PlanDetailType,
                                      coordinator: PlanDetailCoordination) -> PlanDetailViewController
    func makeCommentListViewController() -> CommentListViewController
    
    // MARK: - 이동 뷰
    func makePlaceDetailViewController(place: PlaceInfo,
                                       coordinator: PlaceDetailCoordination) -> PlaceDetailViewController
    func makeMemberListViewController(coordinator: MemberListCoordination) -> MemberListViewController
    
    // MARK: - 이동 플로우
    func makePlanEditFlowCoordiantor(plan: Plan) -> BaseCoordinator
}

final class PlanDetailSceneDIContainer: PlanDetailSceneDependencies {
    
    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    private var mainReactor: PlanDetailViewReactor?
    private let postId: Int
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory,
         postId: Int) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
        self.postId = postId
    }
    
    func makePlanDetailCoordinator(type: PlanDetailType) -> PlanDetailFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController(),
                     type: type)
    }
}

// MARK: - 기본 뷰
extension PlanDetailSceneDIContainer {
    
    // MARK: - 일정 상세
    func makePlanDetailViewController(type: PlanDetailType,
                                      coordinator: PlanDetailCoordination) -> PlanDetailViewController {
        
        return .init(title: type == .plan ? "일정 상세" : "약속 후기",
                     reactor: makePlanDetailViewReactor(type: type,
                                                        coordinator: coordinator))
    }
    
    private func makePlanDetailViewReactor(type: PlanDetailType,
                                           coordinator: PlanDetailCoordination) -> PlanDetailViewReactor {
        mainReactor = PlanDetailViewReactor(type: type,
                                             postId: postId,
                                             fetchPlanDetailUseCase: makeFetchPlanDetailUsecase(),
                                             fetchReviewDetailUseCase: makeFetchReviewDetailUseCase(),
                                             coordinator: coordinator)
        return mainReactor!
    }
    
    private func makeFetchPlanDetailUsecase() -> FetchPlanDetail {
        return FetchPlanDetailUseCase(planRepo: makePlanDetailRepo())
    }
    
    private func makePlanDetailRepo() -> PlanQueryRepo {
        return DefaultPlanQueryRepo(networkService: appNetworkService)
    }
    
    private func makeFetchReviewDetailUseCase() -> FetchReviewDetail {
        return FetchReviewDetailUseCase(reviewListRepo: makeFetchReviewDetailRepo())
    }
    
    private func makeFetchReviewDetailRepo() -> ReviewQueryRepo {
        return DefaultReviewQueryRepo(networkService: appNetworkService)
    }

    // MARK: - 댓글뷰
    func makeCommentListViewController() -> CommentListViewController {
        return .init(reactor: makeCommentListViewReactor())
    }
    
    private func makeCommentListViewReactor() -> CommentListViewReactor {
        let reactor = CommentListViewReactor(postId: postId,
                                             fetchCommentListUseCase: makeFetchCommentListUseCase(),
                                             createCommentUseCase: makeCreateCommentUseCase(),
                                             deleteCommentUseCase: makeDeleteCommentUseCase(),
                                             editCommentUseCase: makeEditCommentUseCase(),
                                             delegate: mainReactor!)
        mainReactor?.setCommentListDelegate(reactor)
        return reactor
    }
    
    private func makeFetchCommentListUseCase() -> FetchCommentList {
        return FetchCommentListUseCase(fetchCommentListRepo: makeFetchCommentListRepo())
    }
    
    private func makeFetchCommentListRepo() -> CommentQueryRepo {
        return DefaultCommentQueryRepo(networkService: appNetworkService)
    }
    
    private func makeCreateCommentUseCase() -> CreateComment {
        return CreateCommentUseCase(createCommentRepo: makeCommentCommandRepo())
    }
    
    private func makeDeleteCommentUseCase() -> DeleteComment {
        return DeleteCommentUseCase(deleteCommentRepo: makeCommentCommandRepo())
    }
    
    private func makeEditCommentUseCase() -> EditComment {
        return EditCommentUseCase(editCommentRepo: makeCommentCommandRepo())
    }
    
    private func makeCommentCommandRepo() -> CommentCommandRepo {
        return DefaultCommentCommandRepo(networkService: appNetworkService)
    }
}

// MARK: - 이동 뷰
extension PlanDetailSceneDIContainer {
    
    // MARK: - 상세 지도
    func makePlaceDetailViewController(place: PlaceInfo,
                                       coordinator: PlaceDetailCoordination) -> PlaceDetailViewController {
        return PlaceDetailViewController(title: "상세 지도",
                                         reactor: makePlaceDetailViewReactor(place: place,
                                                                             coordinator: coordinator))
    }
    
    private func makePlaceDetailViewReactor(place: PlaceInfo, coordinator: PlaceDetailCoordination) -> PlaceDetailReactor {
        return PlaceDetailReactor(place: place,
                                  locationService: DefaultLocationService(),
                                  coordinator: coordinator)
    }
    
    // MARK: - 멤버 리스트
    func makeMemberListViewController(coordinator: MemberListCoordination) -> MemberListViewController {
        return commonFactory.makeMemberListViewController(type: .planMember(id: postId),
                                                          coordinator: coordinator)
    }
}

// MARK: - 이동 플로우
extension PlanDetailSceneDIContainer {
    func makePlanEditFlowCoordiantor(plan: Plan) -> BaseCoordinator {
        return commonFactory.makePlanCreateCoordinator(type: .edit(plan))
    }
}


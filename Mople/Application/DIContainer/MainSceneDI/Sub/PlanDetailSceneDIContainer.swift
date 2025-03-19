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
    func makePlanDetailViewController(coordinator: PlanDetailCoordination) -> PlanDetailViewController
    func makeCommentListViewController() -> CommentListViewController
    
    // MARK: - 이동 뷰
    func makePlaceDetailViewController(place: PlaceInfo,
                                       coordinator: PlaceDetailCoordination) -> PlaceDetailViewController
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController
    func makePhotoBookViewController(imagePaths: [String],
                                     index: Int,
                                     coordinator: NavigationCloseable) -> PhotoBookViewController
    
    // MARK: - 이동 플로우
    func makePlanEditFlowCoordiantor(plan: Plan) -> BaseCoordinator
    func makeReviewEditFlowCoordinator(review: Review) -> BaseCoordinator
}

final class PlanDetailSceneDIContainer: PlanDetailSceneDependencies {
    
    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    private var mainReactor: PlanDetailViewReactor?
    private let type: PlanDetailType
    private let id: Int
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory,
         type: PlanDetailType,
         id: Int) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
        self.type = type
        self.id = id
    }
    
    func makePlanDetailCoordinator() -> PlanDetailFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
    }
}

// MARK: - 기본 뷰
extension PlanDetailSceneDIContainer {
    
    // MARK: - 일정 상세
    func makePlanDetailViewController(coordinator: PlanDetailCoordination) -> PlanDetailViewController {
        print(#function, #line, "Path : # 테스트 55 ")
        return .init(title: getPlanViewTitle(),
                     reactor: makePlanDetailViewReactor(type: type,
                                                        coordinator: coordinator))
    }
    
    private func getPlanViewTitle() -> String {
        if case .plan = type {
            return "일정 상세"
        } else {
            return "약속 후기"
        }
    }
    
    private func makePlanDetailViewReactor(type: PlanDetailType,
                                           coordinator: PlanDetailCoordination) -> PlanDetailViewReactor {
        mainReactor = PlanDetailViewReactor(type: type,
                                            id: id,
                                            fetchPlanDetailUseCase: makeFetchPlanDetailUsecase(),
                                            fetchReviewDetailUseCase: commonFactory.makeFetchReviewDetailUseCase(),
                                            deletePlanUseCase: makeDeletePlanUseCase(),
                                            deleteReviewUseCase: makeDeleteReviewUseCase(),
                                            reportUseCase: commonFactory.makeReportUseCase(),
                                            coordinator: coordinator)
        return mainReactor!
    }
    
    private func makeFetchPlanDetailUsecase() -> FetchPlanDetail {
        return FetchPlanDetailUseCase(
            planRepo: DefaultPlanQueryRepo(networkService: appNetworkService)
        )
    }
    
    private func makeDeletePlanUseCase() -> DeletePlan {
        return DeletePlanUseCase(
            repo: DefaultPlanCommandRepo(networkService: appNetworkService)
        )
    }
    
    private func makeDeleteReviewUseCase() -> DeleteReview {
        return DeleteReviewUseCase(
            repo: DefaultReviewCommnadRepo(networkService: appNetworkService)
        )
    }

    // MARK: - 댓글뷰
    func makeCommentListViewController() -> CommentListViewController {
        return .init(reactor: makeCommentListViewReactor())
    }
    
    private func makeCommentListViewReactor() -> CommentListViewReactor {
        let reactor = CommentListViewReactor(fetchCommentListUseCase: makeFetchCommentListUseCase(),
                                             createCommentUseCase: makeCreateCommentUseCase(),
                                             deleteCommentUseCase: makeDeleteCommentUseCase(),
                                             editCommentUseCase: makeEditCommentUseCase(),
                                             reportUseCase: commonFactory.makeReportUseCase(),
                                             delegate: mainReactor!)
        mainReactor?.commentListCommands = reactor
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
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController {
        return commonFactory.makeMemberListViewController(type: getMemberListType(),
                                                          coordinator: coordinator)
    }
    
    private func getMemberListType() -> MemberListType {
        if case .plan = type {
            return .plan(id: id)
        } else {
            return .review(id: id)
        }
    }
    
    // MARK: - 포토북
    func makePhotoBookViewController(imagePaths: [String],
                                     index: Int,
                                     coordinator: NavigationCloseable) -> PhotoBookViewController {
        return PhotoBookViewController(title: "함께한 순간",
                                       imagePaths: imagePaths,
                                       selectedIndex: index,
                                       coordinator: coordinator)
    }
}

// MARK: - 이동 플로우
extension PlanDetailSceneDIContainer {
    
    // MARK: - 일정 편집
    func makePlanEditFlowCoordiantor(plan: Plan) -> BaseCoordinator {
        return commonFactory.makePlanCreateCoordinator(type: .edit(plan))
    }
    
    // MARK: - 리뷰 편집
    func makeReviewEditFlowCoordinator(review: Review) -> BaseCoordinator {
        return commonFactory.makeReviewEditCoordinator(review: review)
    }
}


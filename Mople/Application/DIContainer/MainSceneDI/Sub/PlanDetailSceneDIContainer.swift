//
//  PlanDetailSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import RxSwift

protocol PlanDetailSceneDependencies {
    func makePlanDetailViewController() -> PlanDetailViewController
    func makeCommentListViewController() -> CommentListViewController
}

final class PlanDetailSceneDIContainer: PlanDetailSceneDependencies {
    
    private let appNetworkService: AppNetworkService
    private let planId: Int
    private var loadingObserver: LoadingStateDelegate?
    
    init(appNetworkService: AppNetworkService,
         planId: Int) {
        self.appNetworkService = appNetworkService
        self.planId = planId
    }
    
    func makePlanDetailCoordinator() -> PlanDetailFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
    }
}

extension PlanDetailSceneDIContainer {
    
    // MARK: - 일정 상세
    func makePlanDetailViewController() -> PlanDetailViewController {
        return .init(title: "약속 상세",
                     reactor: makePlanDetailViewReactor())
    }
    
    private func makePlanDetailViewReactor() -> PlanDetailViewReactor {
        let reactor = PlanDetailViewReactor(planId: planId,
                                            fetchPlanDetailUseCase: makeFetchPlanDetailUsecase())
        loadingObserver = reactor
        return reactor
    }
    
    private func makeFetchPlanDetailUsecase() -> FetchPlanDetail {
        return FetchPlanDetailUseCase(planRepo: makePlanDetailRepo())
    }
    
    private func makePlanDetailRepo() -> PlanQueryRepo {
        return DefaultPlanQueryRepo(networkService: appNetworkService)
    }
    
    // MARK: - 댓글뷰
    func makeCommentListViewController() -> CommentListViewController {
        return .init(reactor: makeCommentListViewReactor(),
                     loadingObserver: loadingObserver)
    }
    
    private func makeCommentListViewReactor() -> CommentListViewReactor {
        return .init(postId: planId,
                     fetchCommentListUseCase: makeFetchCommentListUseCase())
    }
    
    private func makeFetchCommentListUseCase() -> FetchCommentList {
        return FetchCommentListUseCase(fetchCommentListRepo: makeFetchCommentListRepo())
    }
    
    private func makeFetchCommentListRepo() -> CommentQueryRepo {
        return DefaultCommentQueryRepo(networkService: appNetworkService)
    }
}


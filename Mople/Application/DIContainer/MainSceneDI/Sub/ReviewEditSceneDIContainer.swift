//
//  ReviewEditSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 2/6/25.
//

import Foundation

protocol ReviewEditSceneDependencies {
    // MARK: - 기본 뷰
    func makePlanDetailViewController(coordinator: ReviewEditFlowCoordinator) -> ReviewEditViewContoller
    
    // MARK: - 이동 뷰
    
}

final class ReviewEditSceneDIContainer: ReviewEditSceneDependencies {
    
    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    private let reviewId: Int
    private let isReviewed: Bool
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory,
         reviewId: Int,
         isReviewed: Bool = false) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
        self.reviewId = reviewId
        self.isReviewed = isReviewed
    }
    
    func makeReviewEditCoordinator() -> ReviewEditFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
    }
}

extension ReviewEditSceneDIContainer {
    func makePlanDetailViewController(coordinator: ReviewEditFlowCoordinator) -> ReviewEditViewContoller {
        let title = isReviewed ? "후기 수정" : "후기 작성"
        return .init(title: title,
                     reactor: makePlanDetailViewReactor(coordinator: coordinator))
    }
    
    private func makePlanDetailViewReactor(coordinator: ReviewEditFlowCoordinator) -> ReviewEditViewReactor {
        return .init(reviewId: reviewId,
                     fetchReviewDetail: commonFactory.makeFetchReviewDetailUseCase(),
                     coordinator: coordinator)
    }
    
    
}

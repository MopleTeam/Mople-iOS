//
//  ReviewEditSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 2/6/25.
//

import Foundation

protocol ReviewEditSceneDependencies {
    // MARK: - 기본 뷰
    func makeWriteReviewViewController(coordinator: ReviewEditFlowCoordinator) -> ReviewEditViewController
    
    // MARK: - 이동 뷰
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController
    
}

final class ReviewEditSceneDIContainer: ReviewEditSceneDependencies {

    private let appNetworkService: AppNetworkService
    private let commonFactory: ViewDependencies
    private let review: Review
    
    init(appNetworkService: AppNetworkService,
         commonFactory: ViewDependencies,
         review: Review) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
        self.review = review
    }
    
    func makeReviewEditCoordinator() -> ReviewEditFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
    }
}

// MARK: - 기본 뷰
extension ReviewEditSceneDIContainer {
    func makeWriteReviewViewController(coordinator: ReviewEditFlowCoordinator) -> ReviewEditViewController {
        let title = review.isReviewd ? L10n.Review.edit : L10n.Review.create
        return .init(screenName: .review_write,
                     title: title,
                     reactor: makePlanDetailViewReactor(review: review,
                                                        coordinator: coordinator))
    }
    
    private func makePlanDetailViewReactor(review: Review,
                                           coordinator: ReviewEditFlowCoordinator) -> ReviewEditViewReactor {
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
}

// MARK: - 이동 뷰
extension ReviewEditSceneDIContainer {
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController {
        return commonFactory.makeMemberListViewController(type: .review(id: review.id),
                                                          coordinator: coordinator)
    }
}

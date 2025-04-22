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
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController
    
}

final class ReviewEditSceneDIContainer: ReviewEditSceneDependencies {

    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    private let review: Review
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory,
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
    func makePlanDetailViewController(coordinator: ReviewEditFlowCoordinator) -> ReviewEditViewContoller {
        let title = review.isReviewd ? "후기 수정" : "후기 작성"
        return .init(title: title,
                     reactor: makePlanDetailViewReactor(review: review,
                                                        coordinator: coordinator))
    }
    
    private func makePlanDetailViewReactor(review: Review,
                                           coordinator: ReviewEditFlowCoordinator) -> ReviewEditViewReactor {
        return .init(review: review,
                     deleteReviewImage: makeDeleteReviewUseCase(),
                     imageUpload: makeReviewImageUploadUseCase(),
                     photoService: DefaultPhotoService(),
                     coordinator: coordinator)
    }
    
    private func makeDeleteReviewUseCase() -> DeleteReviewImage {
        return DeleteReviewImageUseCase(repo: makeReviewCommandRepo())
    }
    
    private func makeReviewCommandRepo() -> ReviewRepo {
        return DefaultReviewRepo(networkService: appNetworkService)
    }
    
    private func makeReviewImageUploadUseCase() -> ReviewImageUpload {
        return ReviewImageUploadUseCase(repo: makeReviewUploadRepo())
    }
    
    private func makeReviewUploadRepo() -> ImageUploadRepo {
        return DefaultImageUploadRepo(networkService: appNetworkService)
    }
}

// MARK: - 이동 뷰
extension ReviewEditSceneDIContainer {
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController {
        return commonFactory.makeMemberListViewController(type: .review(id: review.id),
                                                          coordinator: coordinator)
    }
}

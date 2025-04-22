//
//  DefaultReviewCommnadRepo.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import RxSwift

final class DefaultReviewRepo: BaseRepositories, ReviewRepo {
    func fetchReviewList(_ meetId: Int) -> Single<[ReviewResponse]> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetReview(id: meetId)
        }
    }
    
    func fetchReviewDetail(_ reviewId: Int) -> Single<ReviewResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchReviewDetail(id: reviewId)
        }
    }
    
    func deleteReviewImage(reviewId: Int, imageIds: [String]) -> Single<Void> {
        networkService.authenticatedRequest {
            try APIEndpoints.deleteReviewImage(reviewId: reviewId, imageIds: imageIds)
        }
    }
    
    func deleteReview(id: Int) -> Single<Void> {
        networkService.authenticatedRequest {
            try APIEndpoints.deleteReview(id: id)
        }
    }
}

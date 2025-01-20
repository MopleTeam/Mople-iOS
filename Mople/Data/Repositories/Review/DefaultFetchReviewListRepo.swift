//
//  ReviewRepo.swift
//  Mople
//
//  Created by CatSlave on 1/10/25.
//
import RxSwift

final class DefaultFetchReviewListRepo: BaseRepositories, ReviewQueryRepo {
    func fetchReviewList(_ meetId: Int) -> Single<[ReviewResponse]> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetReview(meetId: meetId)
        }
    }
    
    func fetchReviewDetail(_ reviewId: Int) -> Single<ReviewResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchReviewDetail(reviewId: reviewId)
        }
    }
}

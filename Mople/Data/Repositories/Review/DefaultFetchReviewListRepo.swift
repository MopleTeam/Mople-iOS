//
//  ReviewRepo.swift
//  Mople
//
//  Created by CatSlave on 1/10/25.
//
import RxSwift

final class DefaultFetchReviewListRepo: BaseRepositories, FetchReviewListRepo {
    func fetchReviewList(_ meetId: Int) -> Single<[ReviewResponse]> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetReview(meetId: meetId)
        }
    }
}

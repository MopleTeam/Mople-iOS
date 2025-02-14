//
//  DefaultReviewCommnadRepo.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import RxSwift

final class DefaultReviewCommnadRepo: BaseRepositories, ReviewCommandRepo {
    func deleteReviewImage(reviewId: Int, imageIds: [String]) -> Single<Void> {
        networkService.authenticatedRequest {
            try APIEndpoints.deleteReviewImage(reviewId: reviewId, imageIds: imageIds)
        }
    }
}

//
//  FetchReviewDetail.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol FetchReviewDetail {
    func execute(reviewId: Int) -> Single<Review>
}

final class FetchReviewDetailUseCase: FetchReviewDetail {
    let reviewListRepo: ReviewQueryRepo
    
    init(reviewListRepo: ReviewQueryRepo) {
        self.reviewListRepo = reviewListRepo
    }
    
    func execute(reviewId: Int) -> Single<Review> {
        return reviewListRepo.fetchReviewDetail(reviewId)
            .map { $0.toDomain() }
    }
}

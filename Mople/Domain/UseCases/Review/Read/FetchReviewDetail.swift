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
    
    private let reviewListRepo: ReviewQueryRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(reviewListRepo: ReviewQueryRepo) {
        self.reviewListRepo = reviewListRepo
    }
    
    func execute(reviewId: Int) -> Single<Review> {
        return reviewListRepo.fetchReviewDetail(reviewId)
            .map { $0.toDomain() }
            .map { [weak self] review in
                var verifyReview = review
                verifyReview.verifyCreator(self?.userID)
                return verifyReview
            }
    }
}

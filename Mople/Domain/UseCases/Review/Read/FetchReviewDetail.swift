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
    
    private let repo: ReviewQueryRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: ReviewQueryRepo) {
        self.repo = repo
    }
    
    func execute(reviewId: Int) -> Single<Review> {
        return repo.fetchReviewDetail(reviewId)
            .map { $0.toDomain() }
            .map { [weak self] review in
                var verifyReview = review
                verifyReview.verifyCreator(self?.userID)
                return verifyReview
            }
    }
}

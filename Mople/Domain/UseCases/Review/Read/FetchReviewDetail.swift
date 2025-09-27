//
//  FetchReviewDetail.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol FetchReviewDetail {
    func execute(id: Int, isOldPlan: Bool) -> Observable<Review>
}

final class FetchReviewDetailUseCase: FetchReviewDetail {
    
    private let repo: ReviewRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: ReviewRepo) {
        self.repo = repo
    }
    
    func execute(id: Int, isOldPlan: Bool) -> Observable<Review> {
        return repo.fetchReviewDetail(id: id, isOldPlan: isOldPlan)
            .map { $0.toDomain() }
            .map { [weak self] review in
                var verifyReview = review
                verifyReview.verifyCreator(self?.userID)
                return verifyReview
            }
            .asObservable()
    }
}

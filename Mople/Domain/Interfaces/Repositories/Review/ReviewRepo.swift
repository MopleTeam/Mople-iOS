//
//  ReviewCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import RxSwift

protocol ReviewRepo {
    func fetchReviewPage(meetId: Int, cursor: String?) -> Single<PageResponse<ReviewResponse>>
    func fetchReviewDetail(_ reviewId: Int) -> Single<ReviewResponse>
    func deleteReviewImage(reviewId: Int, imageIds: [Int]) -> Single<Void>
    func deleteReview(id: Int) -> Single<Void>
}

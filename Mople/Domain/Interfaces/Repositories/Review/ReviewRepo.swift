//
//  ReviewCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import RxSwift

protocol ReviewRepo {
    func fetchReviewList(_ meetId: Int) -> Single<[ReviewResponse]>
    func fetchReviewDetail(_ reviewId: Int) -> Single<ReviewResponse>
    func deleteReviewImage(reviewId: Int, imageIds: [String]) -> Single<Void>
    func deleteReview(id: Int) -> Single<Void>
}

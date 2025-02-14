//
//  FetchReviewImage.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import RxSwift

protocol FetchReviewImage {
    func execute(reviewId: Int) -> Single<[ReviewImage]>
}

final class FetchReviewImageUseCase: FetchReviewImage {
    
    private let reviewListRepo: ReviewQueryRepo
    
    init(reviewListRepo: ReviewQueryRepo) {
        self.reviewListRepo = reviewListRepo
    }
    
    func execute(reviewId: Int) -> Single<[ReviewImage]> {
        return reviewListRepo.fetchReviewImage(reviewId)
            .map { $0.map { response in
                response.toDomain() }
            }
    }
}

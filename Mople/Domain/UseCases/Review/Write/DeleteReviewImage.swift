//
//  DeleteReviewImage.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import RxSwift

protocol DeleteReviewImage {
    func execute(reviewId: Int, imageIds: [String]) -> Observable<Void>
}

final class DeleteReviewImageUseCase: DeleteReviewImage {
    
    private let repo: ReviewRepo
    
    init(repo: ReviewRepo) {
        self.repo = repo
    }
    
    func execute(reviewId: Int, imageIds: [String]) -> Observable<Void> {
        return repo
            .deleteReviewImage(reviewId: reviewId,
                               imageIds: imageIds)
            .asObservable()
    }
}

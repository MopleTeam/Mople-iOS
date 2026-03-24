//
//  DeleteReviewImage.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import RxSwift

protocol DeleteReviewImage {
    func execute(reviewId: Int, imageIds: [Int]) -> Observable<Void>
}

final class DeleteReviewImageUseCase: DeleteReviewImage {
    
    private let repo: ReviewRepo
    
    init(repo: ReviewRepo) {
        self.repo = repo
    }
    
    func execute(reviewId: Int, imageIds: [Int]) -> Observable<Void> {
        return repo
            .deleteReviewImage(reviewId: reviewId,
                               imageIds: imageIds)
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockDeleteReviewImageUseCase: DeleteReviewImage {

    func execute(reviewId: Int, imageIds: [Int]) -> Observable<Void> {
        print("✅ [Mock] DeleteReviewImage - reviewId: \(reviewId), imageIds: \(imageIds)")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif

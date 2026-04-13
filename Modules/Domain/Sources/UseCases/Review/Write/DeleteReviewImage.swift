//
//  DeleteReviewImage.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

public protocol DeleteReviewImage {
    func execute(reviewId: Int, imageIds: [Int]) async throws
}

public final class DeleteReviewImageUseCase: DeleteReviewImage {

    private let repo: ReviewRepo

    public init(repo: ReviewRepo) {
        self.repo = repo
    }

    public func execute(reviewId: Int, imageIds: [Int]) async throws {
        try await repo
            .deleteReviewImage(reviewId: reviewId,
                               imageIds: imageIds)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockDeleteReviewImageUseCase: DeleteReviewImage {
    public init() {}

    public func execute(reviewId: Int, imageIds: [Int]) async throws {
        print("✅ [Mock] DeleteReviewImage - reviewId: \(reviewId), imageIds: \(imageIds)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

//
//  DeleteReview.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation

public protocol DeleteReview {
    func exectue(id: Int) async throws
}

public final class DeleteReviewUseCase: DeleteReview {

    let repo: ReviewRepo

    public init(repo: ReviewRepo) {
        self.repo = repo
    }

    public func exectue(id: Int) async throws {
        try await repo.deleteReview(id: id)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockDeleteReviewUseCase: DeleteReview {
    public init() {}

    public func exectue(id: Int) async throws {
        print("✅ [Mock] DeleteReview - id: \(id)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

//
//  DeleteReview.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation

protocol DeleteReview {
    func exectue(id: Int) async throws
}

final class DeleteReviewUseCase: DeleteReview {

    let repo: ReviewRepo

    init(repo: ReviewRepo) {
        self.repo = repo
    }

    func exectue(id: Int) async throws {
        try await repo.deleteReview(id: id)
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockDeleteReviewUseCase: DeleteReview {

    func exectue(id: Int) async throws {
        print("✅ [Mock] DeleteReview - id: \(id)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

//
//  DeleteComment.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

protocol DeleteComment {
    func execute(commentId: Int) async throws
}

final class DeleteCommentUseCase: DeleteComment {

    private let deleteCommentRepo: CommentRepo

    init(repo: CommentRepo) {
        self.deleteCommentRepo = repo
    }

    func execute(commentId: Int) async throws {
        try await deleteCommentRepo
            .deleteComment(commentId: commentId)
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockDeleteCommentUseCase: DeleteComment {

    func execute(commentId: Int) async throws {
        print("✅ [Mock] DeleteComment - commentId: \(commentId)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

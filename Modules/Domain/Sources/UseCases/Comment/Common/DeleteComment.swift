//
//  DeleteComment.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

public protocol DeleteComment {
    func execute(commentId: Int) async throws
}

public final class DeleteCommentUseCase: DeleteComment {

    private let deleteCommentRepo: CommentRepo

    public init(repo: CommentRepo) {
        self.deleteCommentRepo = repo
    }

    public func execute(commentId: Int) async throws {
        try await deleteCommentRepo
            .deleteComment(commentId: commentId)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockDeleteCommentUseCase: DeleteComment {
    public init() {}

    public func execute(commentId: Int) async throws {
        print("✅ [Mock] DeleteComment - commentId: \(commentId)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

//
//  LikeCOmment.swift
//  Mople
//
//  Created by CatSlave on 7/15/25.
//

import Foundation

public protocol LikeComment {
    func execute(commentId: Int) async throws -> Comment
}

public final class LikeCommentUseCase: LikeComment {

    private let repo: CommentRepo
    private let session: UserSessionProvider

    public init(repo: CommentRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    public func execute(commentId: Int) async throws -> Comment {
        var comment = try await repo.likeComment(commentId: commentId)
        comment.verifyWriter(self.session.currentUserId)
        return comment
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockLikeCommentUseCase: LikeComment {
    public init() {}

    public func execute(commentId: Int) async throws -> Comment {
        print("✅ [Mock] LikeComment - commentId: \(commentId)")

        var mockComment = Comment()
        mockComment.isMockup = true
        mockComment.id = commentId
        mockComment.postId = 1
        mockComment.writerId = 1
        mockComment.writerName = "Mock 사용자"
        mockComment.comment = "좋아요한 댓글"
        mockComment.createdDate = Date()
        mockComment.isWriter = true
        mockComment.isLiked = true
        mockComment.likeCount = 1

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockComment
    }
}
#endif

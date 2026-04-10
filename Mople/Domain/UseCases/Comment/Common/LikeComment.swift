//
//  LikeCOmment.swift
//  Mople
//
//  Created by CatSlave on 7/15/25.
//

import Foundation

protocol LikeComment {
    func execute(commentId: Int) async throws -> Comment
}

final class LikeCommentUseCase: LikeComment {

    private let repo: CommentRepo
    private let session: UserSessionProvider

    init(repo: CommentRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    func execute(commentId: Int) async throws -> Comment {
        let response = try await repo.likeComment(commentId: commentId)
        var domainComment = response.toDomain()
        domainComment.verifyWriter(self.session.currentUserId)
        return domainComment
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockLikeCommentUseCase: LikeComment {

    func execute(commentId: Int) async throws -> Comment {
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

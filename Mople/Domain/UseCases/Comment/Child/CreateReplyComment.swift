//
//  CreateReplyComment.swift
//  Mople
//
//  Created by CatSlave on 7/15/25.
//

import Foundation

protocol CreateReplyComment {
    func execute(postId: Int,
                 parentId: Int,
                 comment: String,
                 mentions: [Int]) async throws -> Comment
}

final class CreateReplyCommentUseCase: CreateReplyComment {

    private let repo: CommentRepo
    private let session: UserSessionProvider

    init(repo: CommentRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    func execute(postId: Int,
                 parentId: Int,
                 comment: String,
                 mentions: [Int]) async throws -> Comment {
        let response = try await repo
            .createReplyComment(postId: postId,
                                commentId: parentId,
                                comment: comment,
                                mentions: mentions)
        var domainComment = response.toDomain()
        domainComment.verifyWriter(self.session.currentUserId)
        return domainComment
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockCreateReplyCommentUseCase: CreateReplyComment {

    func execute(postId: Int,
                 parentId: Int,
                 comment: String,
                 mentions: [Int]) async throws -> Comment {
        print("✅ [Mock] CreateReplyComment - postId: \(postId), parentId: \(parentId), comment: \(comment)")

        var mockReply = Comment()
        mockReply.isMockup = true
        mockReply.id = Int.random(in: 1000...9999)
        mockReply.postId = postId
        mockReply.parentId = parentId
        mockReply.writerId = 1
        mockReply.writerName = "Mock 사용자"
        mockReply.comment = comment
        mockReply.createdDate = Date()
        mockReply.isWriter = true

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockReply
    }
}
#endif

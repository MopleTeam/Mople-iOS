//
//  EditComment.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import Foundation

protocol EditComment {
    func execute(id: Int,
                 text: String,
                 mentions: [Int]) async throws -> Comment
}

final class EditCommentUseCase: EditComment {

    private let editCommentRepo: CommentRepo
    private let session: UserSessionProvider

    init(repo: CommentRepo, session: UserSessionProvider) {
        self.editCommentRepo = repo
        self.session = session
    }

    func execute(id: Int,
                 text: String,
                 mentions: [Int]) async throws -> Comment {
        let response = try await editCommentRepo
            .editComment(commentId: id,
                         comment: text,
                         mentions: mentions)
        var domainComment = response.toDomain()
        domainComment.verifyWriter(self.session.currentUserId)
        return domainComment
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockEditCommentUseCase: EditComment {

    func execute(id: Int,
                 text: String,
                 mentions: [Int]) async throws -> Comment {
        print("✅ [Mock] EditComment - id: \(id), text: \(text), mentions: \(mentions)")

        var mockComment = Comment()
        mockComment.isMockup = true
        mockComment.id = id
        mockComment.postId = 1
        mockComment.writerId = 1
        mockComment.writerName = "Mock 사용자"
        mockComment.comment = text
        mockComment.createdDate = Date()
        mockComment.isWriter = true

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockComment
    }
}
#endif

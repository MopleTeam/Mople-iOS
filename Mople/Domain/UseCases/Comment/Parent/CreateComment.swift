//
//  CreateComment.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

protocol CreateComment {
    func execute(postId: Int,
                 comment: String,
                 mentions: [Int]) async throws -> Comment
}

final class CreateCommentUseCase: CreateComment {

    private let createCommentRepo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id

    init(repo: CommentRepo) {
        self.createCommentRepo = repo
    }

    func execute(postId: Int,
                 comment: String,
                 mentions: [Int]) async throws -> Comment {
        let response = try await createCommentRepo
            .createComment(postId: postId,
                           comment: comment,
                           mentions: mentions)
        var domainComment = response.toDomain()
        domainComment.verifyWriter(self.userId)
        return domainComment
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockCreateCommentUseCase: CreateComment {

    func execute(postId: Int,
                 comment: String,
                 mentions: [Int]) async throws -> Comment {
        print("✅ [Mock] CreateComment - postId: \(postId), comment: \(comment), mentions: \(mentions)")

        var mockComment = Comment()
        mockComment.isMockup = true
        mockComment.id = Int.random(in: 1000...9999)
        mockComment.postId = postId
        mockComment.writerId = 1
        mockComment.writerName = "Mock 사용자"
        mockComment.comment = comment
        mockComment.createdDate = Date()
        mockComment.isWriter = true

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockComment
    }
}
#endif

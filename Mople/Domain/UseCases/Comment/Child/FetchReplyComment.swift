//
//  FetchReplyComment.swift
//  Mople
//
//  Created by CatSlave on 7/15/25.
//

import Foundation

protocol FetchReplyCommentList {
    func execute(postId: Int,
                 commentId: Int,
                 nextCursor: String?) async throws -> Page<Comment>
}

final class FetchReplyCommentListUseCase: FetchReplyCommentList {

    private let repo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id

    init(repo: CommentRepo) {
        self.repo = repo
    }

    func execute(postId: Int,
                 commentId: Int,
                 nextCursor: String?) async throws -> Page<Comment> {
        let response = try await repo.fetchReplyComment(postId: postId,
                                                         commentId: commentId,
                                                         nextCursor: nextCursor)
        let page = Page(totalCount: response.totalCount ?? 0,
                        content: response.content.map({ $0.toDomain() }),
                        info: response.page?.toDomain())
        return checkWriter(with: page)
    }

    private func checkWriter(with list: Page<Comment>) -> Page<Comment> {
        var commentPage = list
        commentPage.content = commentPage.content.map({
            var comment = $0
            comment.verifyWriter(userId)
            return comment
        })
        return commentPage
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchReplyCommentListUseCase: FetchReplyCommentList {

    func execute(postId: Int,
                 commentId: Int,
                 nextCursor: String?) async throws -> Page<Comment> {
        print("✅ [Mock] FetchReplyCommentList - postId: \(postId), commentId: \(commentId), nextCursor: \(nextCursor ?? "nil")")

        let mockReplies: [Comment] = (1...3).map { index in
            var reply = Comment()
            reply.isMockup = true
            reply.id = 100 + index
            reply.postId = postId
            reply.parentId = commentId
            reply.writerId = index
            reply.writerName = "Mock 답글 사용자 \(index)"
            reply.comment = "Mock 답글 내용 \(index)"
            reply.createdDate = Date().addingTimeInterval(Double(-index) * 1800)
            reply.isWriter = index == 1
            return reply
        }

        let page = Page(
            totalCount: mockReplies.count,
            content: mockReplies,
            info: PageInfo(nextCursor: nil, hasNext: false, size: 20)
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return page
    }
}
#endif

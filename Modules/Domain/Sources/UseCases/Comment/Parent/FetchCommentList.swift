//
//  CommentManagement.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import Foundation

public protocol FetchCommentList {
    func execute(postId: Int,
                 nextCursor: String?) async throws -> Page<Comment>
}

public final class FetchCommentListUseCase: FetchCommentList {

    private let repo: CommentRepo
    private let session: UserSessionProvider

    public init(repo: CommentRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    public func execute(postId: Int,
                 nextCursor: String?) async throws -> Page<Comment> {
        let page = try await repo.fetchCommentList(postId: postId,
                                                    nextCursor: nextCursor)
        return checkWriter(with: page)
    }

    private func checkWriter(with list: Page<Comment>) -> Page<Comment> {
        var commentPage = list
        commentPage.content = commentPage.content.map({
            var comment = $0
            comment.verifyWriter(session.currentUserId)
            return comment
        })
        return commentPage
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockFetchCommentListUseCase: FetchCommentList {
    public init() {}

    public func execute(postId: Int,
                 nextCursor: String?) async throws -> Page<Comment> {
        print("✅ [Mock] FetchCommentList - postId: \(postId), nextCursor: \(nextCursor ?? "nil")")

        let mockComments: [Comment] = (1...5).map { index in
            var comment = Comment()
            comment.isMockup = false
            comment.id = index
            comment.postId = postId
            comment.writerId = index
            comment.writerName = "Mock 사용자 \(index)"
            comment.comment = "Mock 댓글 내용 \(index)"
            comment.createdDate = Date().addingTimeInterval(Double(-index) * 3600)
            comment.isWriter = index == 1
            comment.isLiked = index % 2 == 0
            comment.likeCount = index
            comment.replyCount = index > 3 ? 2 : 0
            return comment
        }

        let page = Page(
            totalCount: mockComments.count,
            content: mockComments,
            info: PageInfo(nextCursor: nil, hasNext: false, size: 20)
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return page
    }
}
#endif

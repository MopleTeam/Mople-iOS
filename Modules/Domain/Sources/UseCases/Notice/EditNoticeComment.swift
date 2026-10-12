//
//  CreateNoticeComment.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

public protocol EditNoticeComment {
    func execute(noticeId: Int,
                 content: String,
                 mentions: [Int]) async throws -> Comment
}

public final class EditNoticeCommentUseCase: EditNoticeComment {
    
    private let repo: NoticeRepo
    private let session: UserSessionProvider
    
    public init(repo: NoticeRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }
    
    public func execute(noticeId: Int,
                        content: String,
                        mentions: [Int]) async throws -> Comment {
        var comment = try await repo.editNoticeComment(noticeId: noticeId,
                                                       content: content,
                                                       mentions: mentions)
        comment.verifyWriter(session.currentUserId)
        return comment
    }
}

#if DEV
public final class MockEditNoticeCommentUseCase: EditNoticeComment {
    public init() {}
    
    public func execute(noticeId: Int,
                        content: String,
                        mentions: [Int]) async throws -> Comment {
        print("✅ [Mock] CreateNoticeComment - noticeId: \(noticeId), content: \(content)")
        try await Task.sleep(nanoseconds: 500_000_000)
        var c = Comment()
        c.id = Int.random(in: 1000...9999)
        c.postId = noticeId
        c.writerId = 1
        c.writerName = "Matthew"
        c.comment = content
        c.createdDate = Date()
        c.isWriter = true
        return c
    }
}
#endif

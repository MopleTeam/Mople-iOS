//
//  FetchNoticeCommentList.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

public protocol FetchNoticeCommentList {
    func execute(noticeId: Int,
                 size: Int?,
                 cursor: String?) async throws -> Page<Comment>
}

public final class FetchNoticeCommentListUseCase: FetchNoticeCommentList {

    private let repo: NoticeRepo
    private let session: UserSessionProvider

    public init(repo: NoticeRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    public func execute(noticeId: Int,
                        size: Int?,
                        cursor: String?) async throws -> Page<Comment> {
        let page = try await repo.fetchNoticeCommentList(noticeId: noticeId,
                                                         size: size,
                                                         cursor: cursor)
        var checked = page
        checked.content = checked.content.map {
            var c = $0
            c.verifyWriter(session.currentUserId)
            return c
        }
        return checked
    }
}

#if DEV
public final class MockFetchNoticeCommentListUseCase: FetchNoticeCommentList {
    public init() {}

    public func execute(noticeId: Int,
                        size: Int?,
                        cursor: String?) async throws -> Page<Comment> {
        print("✅ [Mock] FetchNoticeCommentList - noticeId: \(noticeId)")

        let now = Date()
        let mocks: [Comment] = (1...3).map { idx in
            var c = Comment()
            c.id = idx
            c.postId = noticeId
            c.writerId = idx
            c.writerName = ["자바중앙의대총장", "최조르방", "Matthew"][idx - 1]
            c.comment = ["네 확인했습니다", "어이 나한테는 너 무지 친절하구나", "감사합니다!"][idx - 1]
            c.createdDate = now.addingTimeInterval(Double(-idx) * 3600)
            c.isWriter = idx == 3
            return c
        }

        try await Task.sleep(nanoseconds: 500_000_000)
        return Page(totalCount: mocks.count,
                    content: mocks,
                    info: PageInfo(nextCursor: nil, hasNext: false, size: 20))
    }
}
#endif

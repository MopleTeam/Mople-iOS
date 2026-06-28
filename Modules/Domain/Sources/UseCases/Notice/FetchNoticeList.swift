//
//  FetchNoticeList.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

public protocol FetchNoticeList {
    func execute(meetId: Int,
                 size: Int?,
                 cursor: String?) async throws -> Page<Notice>
}

public final class FetchNoticeListUseCase: FetchNoticeList {

    private let repo: NoticeRepo

    public init(repo: NoticeRepo) {
        self.repo = repo
    }

    public func execute(meetId: Int,
                        size: Int?,
                        cursor: String?) async throws -> Page<Notice> {
        return try await repo.fetchNoticeList(meetId: meetId,
                                              size: size,
                                              cursor: cursor)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockFetchNoticeListUseCase: FetchNoticeList {
    public init() {}

    public func execute(meetId: Int,
                        size: Int?,
                        cursor: String?) async throws -> Page<Notice> {
        print("✅ [Mock] FetchNoticeList - meetId: \(meetId), size: \(size ?? -1), cursor: \(cursor ?? "nil")")

        // 모임공지 3개 + 시스템 2개
        let now = Date()
        var notices: [Notice] = []
        for index in 1...3 {
            notices.append(Notice(
                noticeId: index,
                version: 1,
                meetId: meetId,
                type: .custom,
                content: "11/28일 모임 18:00 → 20:00 변경되었습니다. 날씨이슈로 인해서 부득이하게 변경했습니다! (#\(index))",
                writer: UserInfo(id: 1, name: "모임장 매튜", imagePath: nil),
                isPinned: index == 1,
                createdAt: now.addingTimeInterval(Double(-index) * 86400)
            ))
        }
        for index in 4...5 {
            notices.append(Notice(
                noticeId: index,
                version: 1,
                meetId: meetId,
                type: .system,
                content: "[시스템 공지] 새 멤버가 참여했어요. (#\(index))",
                isPinned: false,
                createdAt: now.addingTimeInterval(Double(-index) * 86400)
            ))
        }

        try await Task.sleep(nanoseconds: 500_000_000)
        return Page(totalCount: notices.count,
                    content: notices,
                    info: PageInfo(nextCursor: nil, hasNext: false, size: 20))
    }
}
#endif

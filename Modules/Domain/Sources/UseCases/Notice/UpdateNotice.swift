//
//  UpdateNotice.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

public protocol UpdateNotice {
    func execute(noticeId: Int, meetId: Int, content: String) async throws -> Notice
}

public final class UpdateNoticeUseCase: UpdateNotice {

    private let repo: NoticeRepo

    public init(repo: NoticeRepo) {
        self.repo = repo
    }

    public func execute(noticeId: Int, meetId: Int, content: String) async throws -> Notice {
        return try await repo.updateNotice(noticeId: noticeId,
                                           meetId: meetId,
                                           content: content)
    }
}

#if DEV
public final class MockUpdateNoticeUseCase: UpdateNotice {
    public init() {}

    public func execute(noticeId: Int, meetId: Int, content: String) async throws -> Notice {
        print("✅ [Mock] UpdateNotice - noticeId: \(noticeId), content: \(content)")
        try await Task.sleep(nanoseconds: 600_000_000)
        return Notice(
            noticeId: noticeId,
            version: 2,
            meetId: meetId,
            type: .custom,
            content: content,
            isPinned: false,
            createdAt: Date()
        )
    }
}
#endif

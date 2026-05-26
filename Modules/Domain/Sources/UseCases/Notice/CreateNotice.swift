//
//  CreateNotice.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

public protocol CreateNotice {
    func execute(meetId: Int, content: String) async throws -> Notice
}

public final class CreateNoticeUseCase: CreateNotice {

    private let repo: NoticeRepo

    public init(repo: NoticeRepo) {
        self.repo = repo
    }

    public func execute(meetId: Int, content: String) async throws -> Notice {
        return try await repo.createNotice(meetId: meetId, content: content)
    }
}

#if DEV
public final class MockCreateNoticeUseCase: CreateNotice {
    public init() {}

    public func execute(meetId: Int, content: String) async throws -> Notice {
        print("✅ [Mock] CreateNotice - meetId: \(meetId), content: \(content)")
        try await Task.sleep(nanoseconds: 800_000_000)
        return Notice(
            noticeId: Int.random(in: 1000...9999),
            version: 1,
            meetId: meetId,
            type: .custom,
            content: content,
            isPinned: false,
            createdAt: Date()
        )
    }
}
#endif

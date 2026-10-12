//
//  TogglePinNotice.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

public protocol TogglePinNotice {
    // 현재 고정 상태를 받아서, 반대로 토글된 결과 Notice를 반환.
    func execute(noticeId: Int, isCurrentlyPinned: Bool) async throws -> Notice
}

public final class TogglePinNoticeUseCase: TogglePinNotice {

    private let repo: NoticeRepo

    public init(repo: NoticeRepo) {
        self.repo = repo
    }

    public func execute(noticeId: Int, isCurrentlyPinned: Bool) async throws -> Notice {
        if isCurrentlyPinned {
            return try await repo.unpinNotice(noticeId: noticeId)
        } else {
            return try await repo.pinNotice(noticeId: noticeId)
        }
    }
}

#if DEV
public final class MockTogglePinNoticeUseCase: TogglePinNotice {
    public init() {}

    public func execute(noticeId: Int, isCurrentlyPinned: Bool) async throws -> Notice {
        print("✅ [Mock] TogglePinNotice - noticeId: \(noticeId), nowPinned: \(isCurrentlyPinned)")
        try await Task.sleep(nanoseconds: 400_000_000)
        return Notice(
            noticeId: noticeId,
            version: 2,
            meetId: 0,
            type: .custom,
            content: "Mock 공지 본문",
            isPinned: !isCurrentlyPinned,
            createdAt: Date()
        )
    }
}
#endif

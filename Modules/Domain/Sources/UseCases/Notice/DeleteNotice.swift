//
//  DeleteNotice.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

public protocol DeleteNotice {
    func execute(noticeId: Int) async throws
}

public final class DeleteNoticeUseCase: DeleteNotice {

    private let repo: NoticeRepo

    public init(repo: NoticeRepo) {
        self.repo = repo
    }

    public func execute(noticeId: Int) async throws {
        try await repo.deleteNotice(noticeId: noticeId)
    }
}

#if DEV
public final class MockDeleteNoticeUseCase: DeleteNotice {
    public init() {}

    public func execute(noticeId: Int) async throws {
        print("✅ [Mock] DeleteNotice - noticeId: \(noticeId)")
        try await Task.sleep(nanoseconds: 400_000_000)
    }
}
#endif

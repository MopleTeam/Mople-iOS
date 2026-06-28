//
//  FetchNotice.swift
//  Domain
//
//  Created by CatSlave on 6/12/26.
//

import Foundation

// 공지 단건 상세 조회.
// 상세 화면 진입/새로고침 시 목록에서 건네받은(=stale 가능) Notice 대신 fresh한 값을 받기 위함.
public protocol FetchNotice {
    func execute(noticeId: Int) async throws -> Notice
}

public final class FetchNoticeUseCase: FetchNotice {

    private let repo: NoticeRepo

    public init(repo: NoticeRepo) {
        self.repo = repo
    }

    public func execute(noticeId: Int) async throws -> Notice {
        return try await repo.fetchNoticeDetail(noticeId: noticeId)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockFetchNoticeUseCase: FetchNotice {
    public init() {}

    public func execute(noticeId: Int) async throws -> Notice {
        print("✅ [Mock] FetchNotice - noticeId: \(noticeId)")
        try await Task.sleep(nanoseconds: 300_000_000)
        return Notice(noticeId: noticeId,
                      version: 1,
                      meetId: 1,
                      type: .custom,
                      content: "[단건조회] 새로고침된 공지 내용 (#\(noticeId))",
                      writer: UserInfo(id: 1, name: "모임장 매튜", imagePath: nil),
                      isPinned: false,
                      createdAt: Date())
    }
}
#endif

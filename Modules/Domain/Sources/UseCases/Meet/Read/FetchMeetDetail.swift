//
//  FetchGroup.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation

public protocol FetchMeetDetail {
    func execute(meetId: Int) async throws -> Meet
}

public final class FetchMeetDetailUseCase: FetchMeetDetail {

    private let repo: MeetRepo

    public init(repo: MeetRepo) {
        self.repo = repo
    }

    public func execute(meetId: Int) async throws -> Meet {
        return try await repo.fetchMeetDetail(meetId: meetId)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockFetchMeetDetailUseCase: FetchMeetDetail {
    public init() {}
    public func execute(meetId: Int) async throws -> Meet {
        print("✅ [Mock] 모임 상세 조회 - meetId: \(meetId)")

        let mockPinnedNotice = PinnedNotice(
            noticeId: 1,
            version: 1,
            meetId: meetId,
            type: .custom,
            content: "11/28일 모임 18:00 → 20:00 변경 되었습니다. 날씨이슈로 인해서",
            isPinned: true,
            createdAt: Date()
        )

        let mockMeet = Meet(
            isCreator: true,
            meetSummary: MeetSummary(id: meetId, name: "테니스 동호회"),
            sinceDays: 120,
            creatorId: 1,
            memberCount: 8,
            firstPlanDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            version: 1,
            pinnedNotice: mockPinnedNotice
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockMeet
    }
}
#endif

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
    private let session: UserSessionProvider

    public init(repo: MeetRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    public func execute(meetId: Int) async throws -> Meet {
        var meet = try await repo.fetchMeetDetail(meetId: meetId)
        verifyCreator(with: &meet)
        return meet
    }

    // 서버 MeetResponse엔 isCreator 필드가 없어 default false로 들어온다.
    // FetchMeetPage와 동일한 패턴으로 currentUserId와 creatorId를 비교해 isCreator를 채움.
    // 이 호출이 빠지면 모임장이어도 isCreator=false로 남아 작성 툴팁/연필 버튼 등 모임장 전용 UI가 노출되지 않는다.
    private func verifyCreator(with meet: inout Meet) {
        guard let ownerId = meet.creatorId,
              session.currentUserId == ownerId else { return }
        meet.isCreator = true
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockFetchMeetDetailUseCase: FetchMeetDetail {
    public init() {}
    public func execute(meetId: Int) async throws -> Meet {
        print("✅ [Mock] 모임 상세 조회 - meetId: \(meetId)")

        // meetId 짝수: 공지 있음 / 홀수: 공지 없음 → 모임장 작성 유도 툴팁 노출 케이스 둘 다 확인 가능
        let hasNotice = meetId % 2 == 0
        let mockPinnedNotice: Notice? = hasNotice ? Notice(
            noticeId: 1,
            version: 1,
            meetId: meetId,
            type: .custom,
            content: "11/28일 모임 18:00 → 20:00 변경 되었습니다. 날씨이슈로 인해서",
            isPinned: true,
            createdAt: Date()
        ) : nil

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

//
//  FetchGroup.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation

protocol FetchMeetDetail {
    func execute(meetId: Int) async throws -> Meet
}

final class FetchMeetDetailUseCase: FetchMeetDetail {

    private let repo: MeetRepo

    init(repo: MeetRepo) {
        self.repo = repo
    }

    func execute(meetId: Int) async throws -> Meet {
        let response = try await repo.fetchMeetDetail(meetId: meetId)
        return response.toDomain()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchMeetDetailUseCase: FetchMeetDetail {
    func execute(meetId: Int) async throws -> Meet {
        print("✅ [Mock] 모임 상세 조회 - meetId: \(meetId)")

        let mockMeet = Meet(
            isCreator: true,
            meetSummary: MeetSummary(id: meetId, name: "테니스 동호회"),
            sinceDays: 120,
            creatorId: 1,
            memberCount: 8,
            firstPlanDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockMeet
    }
}
#endif

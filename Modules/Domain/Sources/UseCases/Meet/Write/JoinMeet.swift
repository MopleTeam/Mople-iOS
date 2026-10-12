//
//  JoinMeet.swift
//  Mople
//
//  Created by CatSlave on 4/24/25.
//

import Foundation

public protocol JoinMeet {
    func execute(code: String) async throws -> Meet
}

public final class JoinMeetUseCase: JoinMeet {
    private let repo: MeetRepo

    public init(repo: MeetRepo) {
        self.repo = repo
    }

    public func execute(code: String) async throws -> Meet {
        return try await repo.joinMeet(code: code)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockJoinMeetUseCase: JoinMeet {
    public init() {}
    public func execute(code: String) async throws -> Meet {
        print("✅ [Mock] 모임 참여 - code: \(code)")

        let mockMeet = Meet(
            meetSummary: MeetSummary(id: Int.random(in: 100...999), name: "참여한 모임"),
            sinceDays: 0,
            creatorId: 99,
            memberCount: 4,
            firstPlanDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockMeet
    }
}
#endif

//
//  CreateGroup.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation

public protocol CreateMeet {
    func execute(requset: CreateMeetRequest) async throws -> Meet
}

public final class CreateMeetUseCase: CreateMeet {

    let createMeetRepo: MeetRepo

    public init(createMeetRepo: MeetRepo) {
        self.createMeetRepo = createMeetRepo
    }

    public func execute(requset: CreateMeetRequest) async throws -> Meet {
        return try await self.createMeetRepo.createMeet(reqeust: requset)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockCreateMeetUseCase: CreateMeet {
    public init() {}
    public func execute(requset: CreateMeetRequest) async throws -> Meet {
        print("✅ [Mock] 모임 생성 요청")

        let mockMeet = Meet(
            meetSummary: MeetSummary(id: Int.random(in: 100...999), name: "새로운 모임"),
            sinceDays: 0,
            creatorId: 1,
            memberCount: 1,
            firstPlanDate: nil
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockMeet
    }
}
#endif

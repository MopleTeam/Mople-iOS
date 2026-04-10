//
//  CreateGroup.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation

protocol CreateMeet {
    func execute(requset: CreateMeetRequest) async throws -> Meet
}

final class CreateMeetUseCase: CreateMeet {

    let createMeetRepo: MeetRepo

    init(createMeetRepo: MeetRepo) {
        self.createMeetRepo = createMeetRepo
    }

    func execute(requset: CreateMeetRequest) async throws -> Meet {
        return try await self.createMeetRepo.createMeet(reqeust: requset)
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockCreateMeetUseCase: CreateMeet {
    func execute(requset: CreateMeetRequest) async throws -> Meet {
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

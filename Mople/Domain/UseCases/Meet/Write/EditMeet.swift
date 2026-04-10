//
//  EditMeet.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation

protocol EditMeet {
    func execute(id: Int,
                 request: CreateMeetRequest) async throws -> Meet
}

final class EditMeetUseCase: EditMeet {

    let repo: MeetRepo

    init(repo: MeetRepo) {
        self.repo = repo
    }

    func execute(id: Int,
                 request: CreateMeetRequest) async throws -> Meet {
        let response = try await repo.editMeet(
            id: id,
            reqeust: request)
        return response.toDomain()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockEditMeetUseCase: EditMeet {
    func execute(id: Int,
                 request: CreateMeetRequest) async throws -> Meet {
        print("✅ [Mock] 모임 수정 - meetId: \(id)")

        let mockMeet = Meet(
            isCreator: true,
            meetSummary: MeetSummary(id: id, name: "수정된 모임"),
            sinceDays: 30,
            creatorId: 1,
            memberCount: 5,
            firstPlanDate: nil
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockMeet
    }
}
#endif

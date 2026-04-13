//
//  EditMeet.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation

public protocol EditMeet {
    func execute(id: Int,
                 request: CreateMeetRequest) async throws -> Meet
}

public final class EditMeetUseCase: EditMeet {

    let repo: MeetRepo

    public init(repo: MeetRepo) {
        self.repo = repo
    }

    public func execute(id: Int,
                 request: CreateMeetRequest) async throws -> Meet {
        return try await repo.editMeet(id: id, reqeust: request)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockEditMeetUseCase: EditMeet {
    public init() {}
    public func execute(id: Int,
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

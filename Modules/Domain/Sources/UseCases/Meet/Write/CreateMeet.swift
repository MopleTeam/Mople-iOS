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
    private let session: UserSessionProvider

    public init(createMeetRepo: MeetRepo, session: UserSessionProvider) {
        self.createMeetRepo = createMeetRepo
        self.session = session
    }

    public func execute(requset: CreateMeetRequest) async throws -> Meet {
        var meet = try await self.createMeetRepo.createMeet(reqeust: requset)
        verifyCreator(with: &meet)
        return meet
    }

    // 서버 MeetResponse엔 isCreator 필드가 없어 default false로 들어온다.
    // 모임을 만든 본인이 곧 모임장이지만, 단일 진실 소스(meet.isCreator)를 정상화하기 위해
    // FetchMeetPage/FetchMeetDetail과 동일한 verifyCreator 패턴 적용.
    private func verifyCreator(with meet: inout Meet) {
        guard let ownerId = meet.creatorId,
              session.currentUserId == ownerId else { return }
        meet.isCreator = true
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

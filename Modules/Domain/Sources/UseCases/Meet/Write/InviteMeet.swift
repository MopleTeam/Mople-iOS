//
//  InviteMeet.swift
//  Mople
//
//  Created by CatSlave on 4/24/25.
//

import Foundation

public protocol InviteMeet {
    func execute(id: Int) async throws -> String
}

public final class InviteMeetUseCase: InviteMeet {

    private let repo: MeetRepo

    public init(repo: MeetRepo) {
        self.repo = repo
    }

    public func execute(id: Int) async throws -> String {
        return try await repo.inviteMeet(id: id)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockInviteMeetUseCase: InviteMeet {
    public init() {}
    public func execute(id: Int) async throws -> String {
        print("✅ [Mock] 모임 초대 코드 생성 - meetId: \(id)")

        let mockCode = "MOCK-\(id)-\(String(format: "%04d", Int.random(in: 1000...9999)))"

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockCode
    }
}
#endif

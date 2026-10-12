//
//  DeleteMeet.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation

public protocol DeleteMeet {
    func execute(id: Int) async throws
}

public final class DeleteMeetUseCase: DeleteMeet {

    let repo: MeetRepo

    public init(repo: MeetRepo) {
        self.repo = repo
    }

    public func execute(id: Int) async throws {
        try await repo.deleteMeet(id: id)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockDeleteMeetUseCase: DeleteMeet {
    public init() {}
    public func execute(id: Int) async throws {
        print("✅ [Mock] 모임 삭제 - meetId: \(id)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

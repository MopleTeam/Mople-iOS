//
//  DeleteMeet.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation

protocol DeleteMeet {
    func execute(id: Int) async throws
}

final class DeleteMeetUseCase: DeleteMeet {

    let repo: MeetRepo

    init(repo: MeetRepo) {
        self.repo = repo
    }

    func execute(id: Int) async throws {
        try await repo.deleteMeet(id: id)
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockDeleteMeetUseCase: DeleteMeet {
    func execute(id: Int) async throws {
        print("✅ [Mock] 모임 삭제 - meetId: \(id)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

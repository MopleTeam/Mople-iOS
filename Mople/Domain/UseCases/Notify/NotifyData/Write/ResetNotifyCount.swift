//
//  ResetNotifyCount.swift
//  Mople
//
//  Created by CatSlave on 4/22/25.
//

protocol ResetNotifyCount {
    func execute() async throws
}

final class ResetNotifyCountUseCase: ResetNotifyCount {
    private let repo: NotifyRepo

    init(repo: NotifyRepo) {
        self.repo = repo
    }

    func execute() async throws {
        try await repo.resetNotifyCount()
    }
}

// MARK: - Mock
#if DEV
final class MockResetNotifyCountUseCase: ResetNotifyCount {
    func execute() async throws {
        print("✅ [Mock] 알림 카운트 초기화")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

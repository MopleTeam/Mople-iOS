//
//  ResetNotifyCount.swift
//  Mople
//
//  Created by CatSlave on 4/22/25.
//

public protocol ResetNotifyCount {
    func execute() async throws
}

public final class ResetNotifyCountUseCase: ResetNotifyCount {
    private let repo: NotifyRepo

    public init(repo: NotifyRepo) {
        self.repo = repo
    }

    public func execute() async throws {
        try await repo.resetNotifyCount()
    }
}

// MARK: - Mock
#if DEV
public final class MockResetNotifyCountUseCase: ResetNotifyCount {
    public init() {}
    public func execute() async throws {
        print("✅ [Mock] 알림 카운트 초기화")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

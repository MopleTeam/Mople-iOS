//
//  FetchNotifyState.swift
//  Mople
//
//  Created by CatSlave on 4/11/25.
//

public protocol FetchNotifyState {
    func execute() async throws -> [SubscribeType]
}

public final class FetchNotifyStateUseCase: FetchNotifyState {

    private let repo: NotifySubscribeRepo

    public init(repo: NotifySubscribeRepo) {
        self.repo = repo
    }

    public func execute() async throws -> [SubscribeType] {
        let response = try await repo.fetchNotifyState()
        return response.compactMap { typeString in
            switch typeString {
            case "MEET":
                return .meet
            case "PLAN":
                return .plan
            case "REPLY":
                return .reply
            case "MENTION":
                return .mention
            default:
                return nil
            }
        }
    }
}

// MARK: - Mock
#if DEV
public final class MockFetchNotifyStateUseCase: FetchNotifyState {
    public init() {}
    public func execute() async throws -> [SubscribeType] {
        print("✅ [Mock] 알림 구독 상태 조회")
        let mockState: [SubscribeType] = [.meet, .plan, .mention, .reply]
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockState
    }
}
#endif

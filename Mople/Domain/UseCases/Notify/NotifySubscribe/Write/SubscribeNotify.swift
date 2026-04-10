//
//  SubscribeNotify.swift
//  Mople
//
//  Created by CatSlave on 4/11/25.
//

protocol SubscribeNotify {
    func execute(type: SubscribeType, isSubscribe: Bool) async throws
}

final class SubscribeNotifyUseCase: SubscribeNotify {

    private let repo: NotifySubscribeRepo

    init(repo: NotifySubscribeRepo) {
        self.repo = repo
    }

    func execute(type: SubscribeType, isSubscribe: Bool) async throws {
        try await repo
            .subscribeNotify(type: type,
                             isSubscribe: isSubscribe)
    }
}

// MARK: - Mock
#if DEV
final class MockSubscribeNotifyUseCase: SubscribeNotify {
    func execute(type: SubscribeType, isSubscribe: Bool) async throws {
        print("✅ [Mock] 알림 구독 변경 - type: \(type.rawValue), isSubscribe: \(isSubscribe)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

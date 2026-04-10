//
//  SignOut.swift
//  Mople
//
//  Created by CatSlave on 4/18/25.
//

protocol SignOut {
    func execute(userId: Int) async throws
}

final class SignOutUseCase: SignOut, LifeCycleLoggable {

    private let repo: AuthenticationRepo

    init(repo: AuthenticationRepo) {
        self.repo = repo
        logLifeCycle()
    }

    deinit {
        logLifeCycle()
    }

    func execute(userId: Int) async throws {
        try await repo.signOut(userId: userId)
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockSignOutUseCase: SignOut {

    func execute(userId: Int) async throws {
        print("✅ [Mock] 로그아웃 요청 - userId: \(userId)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 로그아웃 성공")
    }
}
#endif

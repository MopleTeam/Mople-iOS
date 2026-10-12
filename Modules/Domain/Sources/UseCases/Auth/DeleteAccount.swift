//
//  DeleteAccount.swift
//  Mople
//
//  Created by CatSlave on 4/18/25.
//

public protocol DeleteAccount {
    func execute() async throws
}

public final class DeleteAccountUseCase: DeleteAccount, LifeCycleLoggable {

    private let repo: AuthenticationRepo

    public init(repo: AuthenticationRepo) {
        self.repo = repo
        logLifeCycle()
    }

    deinit {
        logLifeCycle()
    }

    public func execute() async throws {
        try await repo.deleteAccount()
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockDeleteAccountUseCase: DeleteAccount {
    public init() {}

    public func execute() async throws {
        print("✅ [Mock] 계정 삭제 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 계정 삭제 성공")
    }
}
#endif

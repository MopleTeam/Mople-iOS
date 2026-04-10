//
//  DeleteAccount.swift
//  Mople
//
//  Created by CatSlave on 4/18/25.
//

protocol DeleteAccount {
    func execute() async throws
}

final class DeleteAccountUseCase: DeleteAccount, LifeCycleLoggable {

    private let repo: AuthenticationRepo

    init(repo: AuthenticationRepo) {
        self.repo = repo
        logLifeCycle()
    }

    deinit {
        logLifeCycle()
    }

    func execute() async throws {
        try await repo.deleteAccount()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockDeleteAccountUseCase: DeleteAccount {

    func execute() async throws {
        print("✅ [Mock] 계정 삭제 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 계정 삭제 성공")
    }
}
#endif

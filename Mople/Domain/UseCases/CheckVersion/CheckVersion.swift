//
//  VersionCheck.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

protocol CheckVersion {
    func executue() async throws -> UpdateStatus
}

final class CheckVersionUseCase: CheckVersion {

    private let repo: AppVersionRepo

    init(repo: AppVersionRepo) {
        self.repo = repo
    }

    func executue() async throws -> UpdateStatus {
        return try await repo.checkForceUpdate()
    }
}

// MARK: - Mock
#if DEV
final class MockCheckVersionUseCase: CheckVersion {
    func executue() async throws -> UpdateStatus {
        print("✅ [Mock] 앱 버전 체크")
        let mockStatus = UpdateStatus(forceUpdate: false,
                                      minVersion: "1.0.0",
                                      message: "")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockStatus
    }
}
#endif

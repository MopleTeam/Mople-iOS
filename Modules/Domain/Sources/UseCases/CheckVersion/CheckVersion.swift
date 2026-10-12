//
//  VersionCheck.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

public protocol CheckVersion {
    func executue() async throws -> UpdateStatus
}

public final class CheckVersionUseCase: CheckVersion {

    private let repo: AppVersionRepo

    public init(repo: AppVersionRepo) {
        self.repo = repo
    }

    public func executue() async throws -> UpdateStatus {
        return try await repo.checkForceUpdate()
    }
}

// MARK: - Mock
#if DEV
public final class MockCheckVersionUseCase: CheckVersion {
    public init() {}
    public func executue() async throws -> UpdateStatus {
        print("✅ [Mock] 앱 버전 체크")
        let mockStatus = UpdateStatus(forceUpdate: false,
                                      minVersion: "1.0.0",
                                      message: "")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockStatus
    }
}
#endif

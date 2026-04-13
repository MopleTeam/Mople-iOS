//
//  Report.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

public protocol ReportPost {
    func execute(type: ReportType,
                 reason: String?) async throws
}

public final class ReportPostUseCase: ReportPost {

    private let repo: ReportRepo

    public init(repo: ReportRepo) {
        self.repo = repo
    }

    public func execute(type: ReportType,
                 reason: String? = nil) async throws {
        let request: ReportRequest = .init(type: type, reason: reason)
        try await repo.reportPost(request: request)
    }
}

// MARK: - Mock
#if DEV
public final class MockReportPostUseCase: ReportPost {
    public init() {}
    public func execute(type: ReportType,
                 reason: String?) async throws {
        print("✅ [Mock] 게시글 신고 - type: \(type), reason: \(reason ?? "없음")")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

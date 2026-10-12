//
//  DeletePlan.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation

public protocol DeletePlan {
    func execute(id: Int) async throws
}

public final class DeletePlanUseCase: DeletePlan {

    let repo: PlanRepo

    public init(repo: PlanRepo) {
        self.repo = repo
    }

    public func execute(id: Int) async throws {
        try await repo.deletePlan(id: id)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockDeletePlanUseCase: DeletePlan {
    public init() {}
    public func execute(id: Int) async throws {
        print("✅ [Mock] 일정 삭제 - planId: \(id)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

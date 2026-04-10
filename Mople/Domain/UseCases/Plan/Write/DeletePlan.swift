//
//  DeletePlan.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation

protocol DeletePlan {
    func execute(id: Int) async throws
}

final class DeletePlanUseCase: DeletePlan {

    let repo: PlanRepo

    init(repo: PlanRepo) {
        self.repo = repo
    }

    func execute(id: Int) async throws {
        try await repo.deletePlan(id: id)
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockDeletePlanUseCase: DeletePlan {
    func execute(id: Int) async throws {
        print("✅ [Mock] 일정 삭제 - planId: \(id)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

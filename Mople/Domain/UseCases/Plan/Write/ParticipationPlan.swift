//
//  RequsetParticipationPlan.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

protocol ParticipationPlan {
    func execute(planId: Int,
                 isJoin: Bool) async throws
}

final class ParticipationPlanUseCase: ParticipationPlan {
    let participationRepo: PlanRepo

    init(participationRepo: PlanRepo) {
        self.participationRepo = participationRepo
    }

    func execute(planId: Int,
                 isJoin: Bool) async throws {
        try await participationRepo
            .participationPlan(planId: planId,
                               isJoin: isJoin)
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockParticipationPlanUseCase: ParticipationPlan {
    func execute(planId: Int,
                 isJoin: Bool) async throws {
        print("✅ [Mock] 일정 참여 변경 - planId: \(planId), isJoin: \(isJoin)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

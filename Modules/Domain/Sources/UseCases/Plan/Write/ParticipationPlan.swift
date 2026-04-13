//
//  RequsetParticipationPlan.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

public protocol ParticipationPlan {
    func execute(planId: Int,
                 isJoin: Bool) async throws
}

public final class ParticipationPlanUseCase: ParticipationPlan {
    let participationRepo: PlanRepo

    public init(participationRepo: PlanRepo) {
        self.participationRepo = participationRepo
    }

    public func execute(planId: Int,
                 isJoin: Bool) async throws {
        try await participationRepo
            .participationPlan(planId: planId,
                               isJoin: isJoin)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockParticipationPlanUseCase: ParticipationPlan {
    public init() {}
    public func execute(planId: Int,
                 isJoin: Bool) async throws {
        print("✅ [Mock] 일정 참여 변경 - planId: \(planId), isJoin: \(isJoin)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif

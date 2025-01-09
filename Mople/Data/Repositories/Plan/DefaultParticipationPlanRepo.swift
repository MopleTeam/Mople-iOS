//
//  DefaultParticipationPlanRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultParticipationPlanRepo: BaseRepositories, ParticipationPlanRepo {
    func requestParticipationPlan(planId: Int,
                                  isJoining: Bool) -> Single<Void> {
        return self.networkService.authenticatedRequest {
            try isJoining ? APIEndpoints.leavePlan(planId: planId) : APIEndpoints.joinPlan(planId: planId)
        }
    }
}

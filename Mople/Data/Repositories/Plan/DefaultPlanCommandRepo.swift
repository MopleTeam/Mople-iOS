//
//  RecentPlanListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultPlanCommandRepo: BaseRepositories, PlanCommandRepo {
    
    func createPlan(_ plan: PlanRequest) -> Single<PlanResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.createPlan(plan)
        }
    }
    
    func requestParticipationPlan(planId: Int,
                                  isJoining: Bool) -> Single<Void> {
        return self.networkService.authenticatedRequest {
            try isJoining ? APIEndpoints.leavePlan(planId: planId) : APIEndpoints.joinPlan(planId: planId)
        }
    }
    
    func editPlan(_ plan: PlanRequest) -> Single<PlanResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.editPlan(plan)
        }
    }
}

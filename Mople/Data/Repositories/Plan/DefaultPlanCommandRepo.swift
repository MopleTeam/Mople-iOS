//
//  RecentPlanListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultPlanCommandRepo: BaseRepositories, PlanCommandRepo {
    
    func createPlan(request: PlanRequest) -> Single<PlanResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.createPlan(request: request)
        }
    }
    
    func participationPlan(planId: Int,
                           isJoining: Bool) -> Single<Void> {
        return networkService.authenticatedRequest {
            try isJoining ? APIEndpoints.leavePlan(id: planId) : APIEndpoints.joinPlan(id: planId)
        }
    }
    
    func editPlan(request: PlanRequest) -> Single<PlanResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.editPlan(request: request)
        }
    }
    
    func deletePlan(id: Int) -> Single<Void> {
        return networkService.authenticatedRequest {
            try APIEndpoints.deletePlan(id: id)
        }
    }
}

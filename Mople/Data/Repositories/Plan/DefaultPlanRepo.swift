//
//  RecentPlanListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultPlanRepo: BaseRepositories, PlanRepo {
    
    func fetchHomeData() -> Single<HomeDataResponse> {
        return self.networkService.authenticatedRequest(endpointClosure: APIEndpoints.fetchRecentPlan)
    }
    
    func fetchPlanDetail(planId: Int) -> Single<PlanResponse> {
        self.networkService.authenticatedRequest {
            try APIEndpoints.fetchPlan(id: planId)
        }
    }
    
    func fetchMeetPlanList(_ meetId: Int) -> Single<[PlanResponse]> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetPlan(id: meetId)
        }
    }
    
    func createPlan(request: PlanRequest) -> Single<PlanResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.createPlan(request: request)
        }
    }
    
    func participationPlan(planId: Int,
                           isJoin: Bool) -> Single<Void> {
        return networkService.authenticatedRequest {
            try isJoin ? APIEndpoints.joinPlan(id: planId) : APIEndpoints.leavePlan(id: planId)
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

//
//  DefaultPlanDetailRepo.swift
//  Mople
//
//  Created by CatSlave on 1/15/25.
//

import RxSwift

final class DefaultPlanQueryRepo: BaseRepositories, PlanQueryRepo {
    
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
}

//
//  DefaultPlanDetailRepo.swift
//  Mople
//
//  Created by CatSlave on 1/15/25.
//

import RxSwift

final class DefaultPlanDetailRepo: BaseRepositories, PlanDetailRepo {
    func fetchPlanDetail(planId: Int) -> Single<PlanResponse> {
        self.networkService.authenticatedRequest {
            try APIEndpoints.fetchPlan(planId: planId)
        }
    }
    
    
}

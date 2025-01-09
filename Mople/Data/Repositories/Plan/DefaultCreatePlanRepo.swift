//
//  DefaultCreatePlanRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import RxSwift

final class DefaultCreatePlanRepo: BaseRepositories, CreatePlanRepo {
    func createPlan(_ plan: CreatePlanRequest) -> Single<PlanResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.createPlan(plan)
        }
    }
}

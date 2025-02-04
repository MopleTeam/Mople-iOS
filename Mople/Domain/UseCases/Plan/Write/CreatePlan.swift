//
//  CreatePlan.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import RxSwift

protocol CreatePlan {
    func execute(with plan: PlanRequest) -> Single<Plan>
}

final class CreatePlanUseCase: CreatePlan {
    let createPlanRepo: PlanCommandRepo
    
    init(createPlanRepo: PlanCommandRepo) {
        self.createPlanRepo = createPlanRepo
    }
    
    func execute(with plan: PlanRequest) -> Single<Plan> {
        return createPlanRepo.createPlan(plan)
            .map {
                var plan = $0.toDomain()
                plan.isCreator = true
                return plan
            }
    }
}

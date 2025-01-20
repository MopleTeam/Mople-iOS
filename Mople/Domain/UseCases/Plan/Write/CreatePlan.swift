//
//  CreatePlan.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import RxSwift

protocol CreatePlan {
    func execute(with plan: CreatePlanRequest) -> Single<Plan>
}

final class CreatePlanUseCase: CreatePlan {
    let createPlanRepo: PlanCommandRepo
    
    init(createPlanRepo: PlanCommandRepo) {
        self.createPlanRepo = createPlanRepo
    }
    
    func execute(with plan: CreatePlanRequest) -> Single<Plan> {
        return createPlanRepo.createPlan(plan)
            .map { $0.toDomain() }
    }
}

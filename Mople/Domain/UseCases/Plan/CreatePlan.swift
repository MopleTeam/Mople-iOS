//
//  CreatePlan.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import RxSwift

protocol CreatePlan {
    func createPlan(with plan: CreatePlanRequest) -> Single<Plan>
}

final class CreatePlanUseCase: CreatePlan {
    let createPlanRepo: CreatePlanRepo
    
    init(createPlanRepo: CreatePlanRepo) {
        self.createPlanRepo = createPlanRepo
    }
    
    func createPlan(with plan: CreatePlanRequest) -> Single<Plan> {
        return createPlanRepo.createPlan(plan)
            .map { $0.toDomain() }
    }
}

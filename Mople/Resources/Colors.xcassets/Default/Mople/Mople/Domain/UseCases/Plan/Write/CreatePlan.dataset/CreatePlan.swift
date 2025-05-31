//
//  CreatePlan.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import RxSwift

protocol CreatePlan {
    func execute(request: PlanRequest) -> Observable<Plan>
}

final class CreatePlanUseCase: CreatePlan {
    let createPlanRepo: PlanRepo
    
    init(createPlanRepo: PlanRepo) {
        self.createPlanRepo = createPlanRepo
    }
    
    func execute(request: PlanRequest) -> Observable<Plan> {
        return createPlanRepo.createPlan(request: request)
            .map {
                var plan = $0.toDomain()
                plan.isCreator = true
                return plan
            }
            .asObservable()
    }
}

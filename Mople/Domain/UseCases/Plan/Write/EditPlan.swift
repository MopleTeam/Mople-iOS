//
//  EditPlan.swift
//  Mople
//
//  Created by CatSlave on 1/31/25.
//

import RxSwift

protocol EditPlan {
    func execute(with plan: PlanRequest) -> Single<Plan>
}

final class EditPlanUseCase: EditPlan {
    let editPlanRepo: PlanCommandRepo
    
    init(editPlanRepo: PlanCommandRepo) {
        self.editPlanRepo = editPlanRepo
    }
    
    func execute(with plan: PlanRequest) -> Single<Plan> {
        return editPlanRepo.editPlan(plan)
            .map {
                var plan = $0.toDomain()
                plan.isCreator = true
                return plan
            }
    }
}

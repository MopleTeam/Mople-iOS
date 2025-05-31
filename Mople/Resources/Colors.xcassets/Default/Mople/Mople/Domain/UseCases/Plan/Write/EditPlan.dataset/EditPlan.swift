//
//  EditPlan.swift
//  Mople
//
//  Created by CatSlave on 1/31/25.
//

import RxSwift

protocol EditPlan {
    func execute(request: PlanRequest) -> Observable<Plan>
}

final class EditPlanUseCase: EditPlan {
    let editPlanRepo: PlanRepo
    
    init(editPlanRepo: PlanRepo) {
        self.editPlanRepo = editPlanRepo
    }
    
    func execute(request: PlanRequest) -> Observable<Plan> {
        return editPlanRepo.editPlan(request: request)
            .map {
                var plan = $0.toDomain()
                plan.isCreator = true
                return plan
            }
            .asObservable()
    }
}

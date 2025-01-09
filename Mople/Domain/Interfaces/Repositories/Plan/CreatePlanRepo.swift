//
//  CreatePlanRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol CreatePlanRepo {
    func createPlan(_ plan: CreatePlanRequest) -> Single<PlanResponse>
}

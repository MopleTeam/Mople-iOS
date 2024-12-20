//
//  CreatePlan.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import RxSwift

protocol CreatePlanUsecase {
    func createPlan(with plan: PlanUploadRequest) -> Single<Plan>
}

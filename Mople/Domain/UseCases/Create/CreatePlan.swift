//
//  CreatePlan.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import RxSwift

protocol CreatePlan {
    func createPlan(with plan: PlanUploadRequest) -> Single<Plan>
}

//
//  FetchPlanDetail.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//
import Foundation
import RxSwift

protocol FetchPlanDetail {
    func execute(planId: Int) -> Single<Plan>
}

final class FetchPlanDetailUseCase: FetchPlanDetail {
    let planRepo: PlanQueryRepo
    
    init(planRepo: PlanQueryRepo) {
        self.planRepo = planRepo
    }
    
    func execute(planId: Int) -> Single<Plan> {
        return planRepo.fetchPlanDetail(planId: planId)
            .map { $0.toDomain() }
    }
}


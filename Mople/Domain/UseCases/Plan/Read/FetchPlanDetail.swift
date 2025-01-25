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
    
    private let planRepo: PlanQueryRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(planRepo: PlanQueryRepo) {
        self.planRepo = planRepo
    }
    
    func execute(planId: Int) -> Single<Plan> {
        return planRepo.fetchPlanDetail(planId: planId)
            .map { $0.toDomain() }
            .map { [weak self] plan in
                var verifyPlan = plan
                verifyPlan.verifyCreator(self?.userID)
                return verifyPlan
            }
    }
}


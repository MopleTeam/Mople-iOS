//
//  FetchPlanDetail.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//
import Foundation
import RxSwift

protocol FetchPlanDetail {
    func execute(planId: Int) -> Observable<Plan>
}

final class FetchPlanDetailUseCase: FetchPlanDetail {
    
    private let repo: PlanRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: PlanRepo) {
        self.repo = repo
    }
    
    func execute(planId: Int) -> Observable<Plan> {
        return repo.fetchPlanDetail(planId: planId)
            .map { $0.toDomain() }
            .map { [weak self] plan in
                var verifyPlan = plan
                verifyPlan.verifyCreator(self?.userID)
                return verifyPlan
            }
            .asObservable()
    }
}


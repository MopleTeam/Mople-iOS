//
//  FetchRecentMeeting.swift
//  Group
//
//  Created by CatSlave on 8/31/24.

import Foundation
import RxSwift

protocol FetchRecentPlan {
    func execute() -> Single<RecentPlan>
}

final class FetchRecentPlanUseCase: FetchRecentPlan {
    let recentPlanRepo: PlanQueryRepo
    
    init(recentPlanRepo: PlanQueryRepo) {
        self.recentPlanRepo = recentPlanRepo
    }
    
    func execute() -> Single<RecentPlan> {
        return recentPlanRepo.fetchRecentPlanList()
            .map { $0.toDomain() }
    }
}






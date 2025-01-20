//
//  FetchRecentMeeting.swift
//  Group
//
//  Created by CatSlave on 8/31/24.

import Foundation
import RxSwift

protocol FetchRecentPlan {
    func fetchRecentPlan() -> Single<RecentPlan>
}

final class FetchRecentPlanUseCase: FetchRecentPlan {
    let recentPlanRepo: PlanQueryRepo
    
    init(recentPlanRepo: PlanQueryRepo) {
        self.recentPlanRepo = recentPlanRepo
    }
    
    func fetchRecentPlan() -> Single<RecentPlan> {
        return recentPlanRepo.fetchRecentPlanList()
            .map { $0.toDomain() }
    }
}






//
//  RecentPlanList.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import RxSwift

protocol PlanCommandRepo {
    func createPlan(_ plan: CreatePlanRequest) -> Single<PlanResponse>
    func requestParticipationPlan(planId: Int,
                                  isJoining: Bool) -> Single<Void>
}

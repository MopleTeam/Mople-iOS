//
//  RecentPlanList.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import RxSwift

protocol PlanCommandRepo {
    func createPlan(request: PlanRequest) -> Single<PlanResponse>
    func participationPlan(planId: Int,
                                  isJoining: Bool) -> Single<Void>
    func editPlan(request: PlanRequest) -> Single<PlanResponse>
    func deletePlan(id: Int) -> Single<Void>
}

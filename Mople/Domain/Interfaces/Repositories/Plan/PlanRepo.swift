//
//  RecentPlanList.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import RxSwift

protocol PlanRepo {
    func fetchHomeData() -> Single<HomeDataResponse>
    func fetchPlanDetail(planId: Int) -> Single<PlanResponse>
    func fetchMeetPlanList(_ meetId: Int) -> Single<[PlanResponse]>
    func createPlan(request: PlanRequest) -> Single<PlanResponse>
    func participationPlan(planId: Int,
                                  isJoin: Bool) -> Single<Void>
    func editPlan(request: PlanRequest) -> Single<PlanResponse>
    func deletePlan(id: Int) -> Single<Void>
}

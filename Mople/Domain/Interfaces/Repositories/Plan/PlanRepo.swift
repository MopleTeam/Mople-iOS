//
//  RecentPlanList.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation

protocol PlanRepo {
    func fetchHomeData() async throws -> HomeDataResponse
    func fetchPlanDetail(planId: Int) async throws -> PlanResponse
    func fetchPlanPage(meetId: Int, cursor: String?) async throws -> PageResponse<PlanResponse>
    func createPlan(request: PlanRequest) async throws -> PlanResponse
    func participationPlan(planId: Int,
                                  isJoin: Bool) async throws
    func editPlan(request: PlanRequest) async throws -> PlanResponse
    func deletePlan(id: Int) async throws
}

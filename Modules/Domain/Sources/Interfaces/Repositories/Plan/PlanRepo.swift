//
//  RecentPlanList.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation

public protocol PlanRepo {
    func fetchHomeData() async throws -> HomeData
    func fetchPlanDetail(planId: Int) async throws -> Plan
    func fetchPlanPage(meetId: Int, cursor: String?) async throws -> Page<Plan>
    func createPlan(request: PlanRequest) async throws -> Plan
    func participationPlan(planId: Int, isJoin: Bool) async throws
    func editPlan(request: PlanRequest) async throws -> Plan
    func deletePlan(id: Int) async throws
}

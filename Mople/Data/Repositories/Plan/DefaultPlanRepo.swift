//
//  RecentPlanListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

final class DefaultPlanRepo: BaseRepositories, PlanRepo {

    func fetchHomeData() async throws -> HomeDataResponse {
        return try await self.networkService.authenticatedRequest(endpointClosure: APIEndpoints.fetchRecentPlan)
    }

    func fetchPlanDetail(planId: Int) async throws -> PlanResponse {
        return try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchPlan(id: planId)
        }
    }

    func fetchPlanPage(meetId: Int, cursor: String?) async throws -> PageResponse<PlanResponse> {
        return try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchPlanPage(meetId: meetId, cursor: cursor)
        }
    }

    func createPlan(request: PlanRequest) async throws -> PlanResponse {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.createPlan(request: request)
        }
    }

    func participationPlan(planId: Int,
                           isJoin: Bool) async throws {
        return try await networkService.authenticatedRequest {
            try isJoin ? APIEndpoints.joinPlan(id: planId) : APIEndpoints.leavePlan(id: planId)
        }
    }

    func editPlan(request: PlanRequest) async throws -> PlanResponse {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.editPlan(request: request)
        }
    }

    func deletePlan(id: Int) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.deletePlan(id: id)
        }
    }
}

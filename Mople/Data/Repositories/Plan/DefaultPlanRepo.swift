//
//  RecentPlanListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Domain

final class DefaultPlanRepo: BaseRepositories, PlanRepo {

    func fetchHomeData() async throws -> HomeData {
        let response: HomeDataResponse = try await self.networkService.authenticatedRequest(
            endpointClosure: APIEndpoints.fetchRecentPlan
        )
        return response.toDomain()
    }

    func fetchPlanDetail(planId: Int) async throws -> Plan {
        let response: PlanResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchPlan(id: planId)
        }
        return response.toDomain()
    }

    func fetchPlanPage(meetId: Int, cursor: String?) async throws -> Page<Plan> {
        let response: PageResponse<PlanResponse> = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchPlanPage(meetId: meetId, cursor: cursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    func createPlan(request: PlanRequest) async throws -> Plan {
        let dto = PlanRequestDTO(request: request)
        let response: PlanResponse = try await networkService.authenticatedRequest {
            try APIEndpoints.createPlan(request: dto)
        }
        return response.toDomain()
    }

    func participationPlan(planId: Int, isJoin: Bool) async throws {
        return try await networkService.authenticatedRequest {
            try isJoin ? APIEndpoints.joinPlan(id: planId) : APIEndpoints.leavePlan(id: planId)
        }
    }

    func editPlan(request: PlanRequest) async throws -> Plan {
        let dto = PlanRequestDTO(request: request)
        let response: PlanResponse = try await networkService.authenticatedRequest {
            try APIEndpoints.editPlan(request: dto)
        }
        return response.toDomain()
    }

    func deletePlan(id: Int) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.deletePlan(id: id)
        }
    }
}

//
//  DefaultReportRepo.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import Domain

final class DefaultReportRepo: BaseRepositories, ReportRepo {
    func reportPost(request: ReportRequest) async throws {
        let dto = ReportRequestDTO(request: request)
        try await networkService.authenticatedRequest {
            return try APIEndpoints.report(request: dto)
        }
    }
}

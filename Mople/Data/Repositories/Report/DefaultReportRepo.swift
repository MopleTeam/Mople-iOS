//
//  DefaultReportRepo.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

final class DefaultReportRepo: BaseRepositories, ReportRepo {
    func reportPost(request: ReportRequest) async throws {
        try await networkService.authenticatedRequest {
            return try APIEndpoints.report(request: request)
        }
    }
}

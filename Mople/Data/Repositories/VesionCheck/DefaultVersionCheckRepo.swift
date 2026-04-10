//
//  DefaultVersionCheckRepo.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

final class DefaultAppVersionRepo: BaseRepositories, AppVersionRepo {
    func checkForceUpdate() async throws -> UpdateStatusResponse {
        let endpoint = APIEndpoints.checkAppVersionUpdate()
        return try await networkService.basicRequest(endpoint: endpoint)
    }
}

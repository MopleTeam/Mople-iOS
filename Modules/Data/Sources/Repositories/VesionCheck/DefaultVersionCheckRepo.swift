//
//  DefaultVersionCheckRepo.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

import Domain

public final class DefaultAppVersionRepo: BaseRepositories, AppVersionRepo {
    public func checkForceUpdate() async throws -> UpdateStatus {
        let response: UpdateStatusResponse = try await networkService.basicRequest(
            endpoint: APIEndpoints.checkAppVersionUpdate()
        )
        return response.toDomain()
    }
}

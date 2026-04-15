//
//  DefaultSearchLocationRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Domain

public final class DefaultSearchPlaceRepo: BaseRepositories, SearchPlaceRepo {
    public func search(request: SearchLocationRequest) async throws -> SearchPlaceResult {
        let dto = SearchLocationRequestDTO(request: request)
        let response: SearchPlaceResultResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.searchPlace(request: dto)
        }
        return response.toDomain()
    }
}

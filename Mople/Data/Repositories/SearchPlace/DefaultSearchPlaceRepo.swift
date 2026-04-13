//
//  DefaultSearchLocationRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

final class DefaultSearchPlaceRepo: BaseRepositories, SearchPlaceRepo {
    func search(request: SearchLocationRequest) async throws -> SearchPlaceResult {
        let response: SearchPlaceResultResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.searchPlace(request: request)
        }
        return response.toDomain()
    }
}

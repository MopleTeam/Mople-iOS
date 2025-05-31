//
//  DefaultSearchLocationRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultSearchPlaceRepo: BaseRepositories, SearchPlaceRepo {
    func search(request: SearchLocationRequest) -> Single<SearchPlaceResultResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.searchPlace(request: request)
        }
    }
}

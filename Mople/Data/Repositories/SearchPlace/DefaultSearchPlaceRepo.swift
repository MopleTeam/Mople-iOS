//
//  DefaultSearchLocationRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultSearchPlaceRepo: BaseRepositories, SearchPlaceRepo {
    func search(_ locationRequset: SearchLocationReqeust) -> Single<SearchPlaceResultResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.searchPlace(locationRequset)
        }
    }
}

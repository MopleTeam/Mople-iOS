//
//  DefaultSearchLocationRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultSearchLocationRepo: BaseRepositories, SearchLocationRepo {
    func searchLocation(_ locationRequset: SearchLocationReqeust) -> Single<SearchPlaceResultResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.searchLoaction(locationRequset)
        }
    }
}

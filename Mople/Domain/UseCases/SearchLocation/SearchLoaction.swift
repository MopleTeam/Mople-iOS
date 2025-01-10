//
//  SearchLoaction.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import RxSwift

protocol SearchLoaction {
    func requestSearchLocation(query: String,
                               x: Double?,
                               y: Double?) -> Single<SearchPlaceResult>
}

final class SearchLoactionUseCase: SearchLoaction {
        
    let searchLocationRepo: SearchLocationRepo
    
    init(searchLocationRepo: SearchLocationRepo) {
        self.searchLocationRepo = searchLocationRepo
    }
    
    func requestSearchLocation(query: String,
                               x: Double?,
                               y: Double?) -> Single<SearchPlaceResult> {
        
        return searchLocationRepo
            .searchLocation(.init(query: query, x: x, y: y))
            .map { $0.toDomain() }
    }
}

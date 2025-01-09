//
//  SearchLoaction.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import RxSwift
import CoreLocation


protocol SearchLoaction {
    func requestSearchLocation(query: String) -> Single<SearchPlaceResult>
}

final class SearchLoactionUseCase: SearchLoaction {
    
    let locationManaber = CLLocationManager()
    
    let searchLocationRepo: SearchLocationRepo
    
    init(searchLocationRepo: SearchLocationRepo) {
        self.searchLocationRepo = searchLocationRepo
    }
    
    func requestSearchLocation(query: String) -> Single<SearchPlaceResult> {
        
        
        
        return searchLocationRepo
            .searchLocation(.init(query: query, x: nil, y: nil))
            .map { $0.toDomain() }
    }
}

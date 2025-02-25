//
//  SearchLoaction.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import RxSwift

protocol SearchPlace {
    func execute(query: String,
                 x: Double?,
                 y: Double?) -> Single<SearchPlaceResult>
}

final class SearchPlaceUseCase: SearchPlace {
        
    private let searchPlaceRepo: SearchPlaceRepo
    
    init(searchPlaceRepo: SearchPlaceRepo) {
        self.searchPlaceRepo = searchPlaceRepo
    }
    
    func execute(query: String,
                 x: Double?,
                 y: Double?) -> Single<SearchPlaceResult> {
        
        return searchPlaceRepo
            .search(request: .init(query: query, x: x, y: y))
            .map { $0.toDomain() }
    }
}

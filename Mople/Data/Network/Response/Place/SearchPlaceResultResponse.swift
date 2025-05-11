//
//  SearchLocationResponse.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import Foundation

struct SearchPlaceResultResponse: Decodable {
    let searchResult: [PlaceInfoResponse]
    let page: Int
    let isEnd: Bool
}

extension SearchPlaceResultResponse {
    func toDomain() -> SearchPlaceResult {
        return .init(places: searchResult.map({ $0.toDomain() }),
                     page: page,
                     isEnd: isEnd)
    }
}

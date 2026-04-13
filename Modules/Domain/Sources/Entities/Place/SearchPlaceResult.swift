//
//  SearchPlaceResult.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import Foundation

public struct SearchPlaceResult {
    public let places: [PlaceInfo]
    public let page: Int
    public let isEnd: Bool

    public init(places: [PlaceInfo], page: Int, isEnd: Bool) {
        self.places = places
        self.page = page
        self.isEnd = isEnd
    }
}

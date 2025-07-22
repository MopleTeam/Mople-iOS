//
//  SearchPlaceTableCellModel.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

struct SearchPlaceViewModel {
    var title: String?
    var address: String?
}

extension SearchPlaceViewModel {
    init(placeInfo: PlaceInfo) {
        self.title = placeInfo.title ?? L10n.Searchplace.nonName
        self.address = placeInfo.roadAddress
    }
}

//
//  Location.swift
//  Group
//
//  Created by CatSlave on 11/6/24.
//

import Foundation

struct LocationInfo: Hashable, Equatable {
    let detailAddress: String?
    let longitude: Double?
    let latitude: Double?
    
    init(detailAddress: String? = nil,
         longitude: Double? = nil,
         latitude: Double? = nil) {
        self.detailAddress = detailAddress
        self.longitude = longitude
        self.latitude = latitude
    }
}

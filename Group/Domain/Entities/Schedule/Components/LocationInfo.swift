//
//  Location.swift
//  Group
//
//  Created by CatSlave on 11/6/24.
//

import Foundation

struct LocationInfo: Hashable, Equatable {
    let longitude: Double?
    let latitude: Double?
    
    init(longitude: Double? = nil,
         latitude: Double? = nil) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

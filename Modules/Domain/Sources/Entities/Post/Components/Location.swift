//
//  Location.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

public struct Location: Hashable {
    public let longitude: Double?
    public let latitude: Double?

    public init(longitude: Double? = nil, latitude: Double? = nil) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

public extension Location {
    public init?(lat: Double?, lot: Double?) {
        guard let lat, let lot else { return nil }
        longitude = lot
        latitude = lat
    }
    
    public static var defaultLocation: Self {
        return .init(longitude: 126.976894, latitude: 37.575968)
    }
}

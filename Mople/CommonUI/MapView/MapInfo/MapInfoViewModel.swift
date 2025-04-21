//
//  MapInfoViewModel.swift
//  Mople
//
//  Created by CatSlave on 4/18/25.
//

import Foundation

struct MapInfoViewModel {
    let title: String?
    let address: String?
    let location: Location?
    private let distance: Int?
    
    var distanceText: String? {
        guard let distance = distance else { return nil }
        
        switch distance {
        case 1..<1000:
            return "\(distance)m"
        case 1000...:
            let kilometers = Double(distance) / 1000
            let rounded = round(kilometers * 10) / 10
            let roundedDistance = Int(rounded)
            return "\(roundedDistance)km"
        default:
            return nil
        }
    }
}

extension MapInfoViewModel {
    init(place: PlaceInfo) {
        self.title = place.title
        self.address = place.roadAddress
        self.location = place.location
        self.distance = place.distance
    }
}

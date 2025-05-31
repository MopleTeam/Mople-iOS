//
//  SearchLocation.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import Foundation
import NMapsMap

struct PlaceInfo {
    var uuid: String?
    let title: String?
    var distance: Int?
    let address: String?
    let roadAddress: String?
    let location: Location?
    
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

extension PlaceInfo {
    init(post: PostSummary) {
        self.title = post.addressTitle ?? L10n.nonName
        self.address = nil
        self.roadAddress = post.address
        self.location = post.location
    }
}

extension PlaceInfo {
    mutating func updateDistance(userLocation: Location?) {
        guard let location,
              let placeLat = location.latitude,
              let placeLng = location.longitude,
              let userLat = userLocation?.latitude,
              let userLng = userLocation?.longitude else { return }
        
        let point1 = NMGLatLng(lat: placeLat,
                               lng: placeLng)
        
        let point2 = NMGLatLng(lat: userLat,
                               lng: userLng)

        let calculateDistance = point1.distance(to: point2)
        distance = Int(round(calculateDistance))
    }
}


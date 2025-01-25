//
//  SearchLocation.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import Foundation
import CoreLocation
import NMapsMap

struct PlaceInfo {
    var uuid: String?
    let title: String?
    var distance: Int?
    let address: String?
    let roadAddress: String?
    let location: Location?
}

extension PlaceInfo {
    mutating func updateDistance(userLocation: CLLocationCoordinate2D?) {
        guard let location,
              let lat = location.latitude,
              let lng = location.longitude,
              let userLocation else { return }

        let point1 = NMGLatLng(lat: lat,
                               lng: lng)
        
        let point2 = NMGLatLng(lat: userLocation.latitude,
                               lng: userLocation.longitude)

        let calculateDistance = point1.distance(to: point2)
        distance = Int(round(calculateDistance))
    }
}


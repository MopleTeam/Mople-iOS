//
//  UploadLocation.swift
//  Mople
//
//  Created by CatSlave on 12/17/24.
//

import Foundation

struct UploadPlace: Encodable {
    let title: String
    let planAddress: String
    let lat: Double
    let lot: Double
    let weatherAddress: String
}

extension UploadPlace {
    init(place: PlaceInfo) {
        self.title = place.title ?? ""
        self.planAddress = place.roadAddress ?? ""
        self.lat = place.location?.latitude ?? 37.575968
        self.lot = place.location?.longitude ?? 126.976894
        self.weatherAddress = place.address ?? ""
    }
}

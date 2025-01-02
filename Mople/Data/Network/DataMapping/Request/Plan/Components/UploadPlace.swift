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
        self.planAddress = place.address ?? ""
        self.lat = place.latitude ?? 0
        self.lot = place.longitude ?? 0
        self.weatherAddress = place.roadAddress ?? ""
    }
}

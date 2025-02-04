//
//  UploadLocation.swift
//  Mople
//
//  Created by CatSlave on 12/17/24.
//

import Foundation

struct UploadPlace: Encodable, Equatable {
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
    
    init(plan: Plan) {
        self.title = plan.addressTitle ?? ""
        self.planAddress = plan.address ?? ""
        self.lat = plan.location?.latitude ?? 37.575968
        self.lot = plan.location?.longitude ?? 126.976894
        self.weatherAddress = plan.weather?.address ?? ""
    }
}

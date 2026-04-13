//
//  UploadLocation.swift
//  Mople
//
//  Created by CatSlave on 12/17/24.
//

import Foundation
import Domain

struct UploadPlace: Encodable, Equatable {
    let title: String?
    let planAddress: String?
    let lat: Double?
    let lot: Double?
    let weatherAddress: String?
}

extension UploadPlace {
    init(place: PlaceInfo) {
        self.title = place.title
        self.planAddress = place.roadAddress
        self.lat = place.location?.latitude
        self.lot = place.location?.longitude
        self.weatherAddress = place.address
    }
    
    init(plan: Plan) {
        self.title = plan.addressTitle
        self.planAddress = plan.address
        self.lat = plan.location?.latitude
        self.lot = plan.location?.longitude
        self.weatherAddress = plan.weather?.address
    }
}

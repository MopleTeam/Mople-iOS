//
//  PlanCreate.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

struct CreatePlanRequest: Encodable {
    let meetId: Int
    let name: String
    let date: String
    let title: String
    let planAddress: String
    let lat: Double
    let lot: Double
    let weatherAddress: String
    
    enum CodingKeys: String, CodingKey {
        case meetId, name
        case date = "planTime"
    }
}

extension CreatePlanRequest {
    init(meetId: Int,
         name: String,
         date: String,
         place: PlaceInfo) {
        
        self.meetId = meetId
        self.name = name
        self.date = date
        self.title = place.title ?? ""
        self.planAddress = place.address ?? ""
        self.lat = place.latitude ?? 0
        self.lot = place.longitude ?? 0
        self.weatherAddress = place.roadAddress ?? ""
    }
}

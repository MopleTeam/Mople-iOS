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
        case meetId, name, title, planAddress, lat, lot, weatherAddress
        case date = "planTime"
    }
}

extension CreatePlanRequest {
    init(meetId: Int,
         name: String,
         date: String,
         place: UploadPlace) {
        
        self.meetId = meetId
        self.name = name
        self.date = date
        self.title = place.title
        self.planAddress = place.planAddress
        self.lat = place.lat
        self.lot = place.lot
        self.weatherAddress = place.weatherAddress
    }
}

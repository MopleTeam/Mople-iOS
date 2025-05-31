//
//  PlanCreate.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

enum PlanRequestType {
    case create(meetId: Int)
    case edit(planId: Int)
}

struct PlanRequest: Encodable {
    let type: PlanRequestType
    let name: String
    let date: String
    let title: String
    let planAddress: String
    let lat: Double
    let lot: Double
    let weatherAddress: String
    
    enum CodingKeys: String, CodingKey {
        case name, title, planAddress, lat, lot, weatherAddress, planId, meetId
        case date = "planTime"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(title, forKey: .title)
        try container.encode(planAddress, forKey: .planAddress)
        try container.encode(date, forKey: .date)
        try container.encode(lat, forKey: .lat)
        try container.encode(lot, forKey: .lot)
        try container.encode(weatherAddress, forKey: .weatherAddress)
        
        switch type {
        case let .create(meetId):
            try container.encode(meetId, forKey: .meetId)
        case let .edit(planId):
            try container.encode(planId, forKey: .planId)
        }   
    }
}

extension PlanRequest {
    init(type: PlanRequestType,
         name: String,
         date: String,
         place: UploadPlace) {
        
        self.type = type
        self.name = name
        self.date = date
        self.title = place.title
        self.planAddress = place.planAddress
        self.lat = place.lat
        self.lot = place.lot
        self.weatherAddress = place.weatherAddress
    }
}

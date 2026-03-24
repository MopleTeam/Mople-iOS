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
    var description: String?
    var place: UploadPlace?
    
    enum CodingKeys: String, CodingKey {
        case name, title, planAddress, lat, lot, weatherAddress, planId, meetId, description
        case date = "planTime"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(place?.title, forKey: .title)
        try container.encodeIfPresent(place?.planAddress, forKey: .planAddress)
        try container.encodeIfPresent(place?.lat, forKey: .lat)
        try container.encodeIfPresent(place?.lot, forKey: .lot)
        try container.encodeIfPresent(place?.weatherAddress, forKey: .weatherAddress)
        try container.encodeIfPresent(description, forKey: .description)
        
        switch type {
        case let .create(meetId):
            try container.encode(meetId, forKey: .meetId)
        case let .edit(planId):
            try container.encode(planId, forKey: .planId)
        }   
    }
}

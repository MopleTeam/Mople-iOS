//
//  PlanCreate.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

struct PlanRequest: Encodable {
    var meetId: Int?
    var name: String?
    var date: String?
    var address: String?
    var lot: Double?
    var lat: Double?
    var weatherAddress: String?
    
    var isValid: Bool {
        guard let _ = meetId,
              let _ = address,
              let _ = lot,
              let _ = lat,
              let _ = weatherAddress,
              let name = name else { return false }
        return !name.isEmpty
    }
    
    enum CodingKeys: String, CodingKey {
        case meetId, name, lot, lat, weatherAddress
        case date = "planTime"
        case address = "planAddress"
    }
    
    mutating func updateDate(on date: Date) {
        self.date = DateManager.toServerDateString(date)
    }
    
    mutating func updateLocation(_ location: (lot: Double, lat: Double)) {
        self.lot = location.lot
        self.lat = location.lat
    }
}

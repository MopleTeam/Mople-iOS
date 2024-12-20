//
//  UploadLocation.swift
//  Mople
//
//  Created by CatSlave on 12/17/24.
//

import Foundation

struct UploadLocation: Encodable {
    var title: String?
    var address: String?
    var lat: Double?
    var lot: Double?
    var weatherAddress: String?
    
    var isValid: Bool {
        guard let _ = title,
              let _ = address,
              let _ = lat,
              let _ = lot,
              let _ = weatherAddress else { return false }
        return true
    }
    
    enum CodingKeys: String, CodingKey {
        case title, lot, lat, weatherAddress
        case address = "planAddress"
    }
    
    mutating func updateLocation(_ location: (lot: Double, lat: Double)) {
        self.lot = location.lot
        self.lat = location.lat
    }
}

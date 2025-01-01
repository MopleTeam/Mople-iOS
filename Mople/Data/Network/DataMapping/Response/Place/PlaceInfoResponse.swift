//
//  Location.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import Foundation


struct PlaceInfoResponse: Decodable {
    let title: String?
    let distance: String?
    let address: String?
    let roadAddress: String?
    let x: String?
    let y: String?
}

extension PlaceInfoResponse {
    func toDomain() -> PlaceInfo {
        return .init(title: title,
                     distance: getDistance(),
                     address: address,
                     roadAddress: roadAddress,
                     longitude: getLongitude(),
                     latitude: getLatitude())

    }
    
    private func getDistance() -> Int {
        guard let distanceText = self.distance,
              let distance = Int(distanceText) else { return 0 }
        return distance
    }
    
    private func getLongitude() -> Double {
        guard let x,
              let longitude = Double(x) else { return 0 }
        return longitude
    }
    
    private func getLatitude() -> Double {
        guard let y,
              let latitude = Double(y) else { return 0 }
        return latitude
    }
}




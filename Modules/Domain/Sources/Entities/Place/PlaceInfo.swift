//
//  SearchLocation.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import Foundation

public struct PlaceInfo: Equatable {
    public var uuid: String?
    public let title: String?
    public var distance: Int?
    public let address: String?
    public let roadAddress: String?
    public let location: Location?

    public init(uuid: String? = nil, title: String? = nil, distance: Int? = nil, address: String? = nil, roadAddress: String? = nil, location: Location? = nil) {
        self.uuid = uuid
        self.title = title
        self.distance = distance
        self.address = address
        self.roadAddress = roadAddress
        self.location = location
    }

    public var distanceText: String? {
        guard let distance = distance else { return nil }
        
        switch distance {
        case 1..<1000:
            return "\(distance)m"
        case 1000...:
            let kilometers = Double(distance) / 1000
            let rounded = round(kilometers * 10) / 10
            let roundedDistance = Int(rounded)
            return "\(roundedDistance)km"
        default:
            return nil
        }
    }
}

public extension PlaceInfo {
    /// Plan에서 장소 정보 추출
    init(plan: Plan) {
        self.uuid = nil
        self.title = plan.addressTitle
        self.distance = nil
        self.address = plan.weather?.address
        self.roadAddress = plan.address
        self.location = plan.location
    }
}

public extension PlaceInfo {
    /// 사용자 위치 기준 거리 계산 (Haversine 공식 — NMapsMap 의존 제거)
    public mutating func updateDistance(userLocation: Location?) {
        guard let location,
              let placeLat = location.latitude,
              let placeLng = location.longitude,
              let userLat = userLocation?.latitude,
              let userLng = userLocation?.longitude else { return }

        let calculateDistance = Self.haversineDistance(
            lat1: userLat, lng1: userLng,
            lat2: placeLat, lng2: placeLng
        )
        distance = Int(round(calculateDistance))
    }

    /// Haversine 공식으로 두 좌표 간 거리(m) 계산
    private static func haversineDistance(lat1: Double, lng1: Double,
                                          lat2: Double, lng2: Double) -> Double {
        let earthRadius: Double = 6_371_000 // 지구 반지름 (미터)
        let dLat = (lat2 - lat1) * .pi / 180
        let dLng = (lng2 - lng1) * .pi / 180
        let radLat1 = lat1 * .pi / 180
        let radLat2 = lat2 * .pi / 180

        let a = sin(dLat / 2) * sin(dLat / 2)
              + cos(radLat1) * cos(radLat2) * sin(dLng / 2) * sin(dLng / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }
}


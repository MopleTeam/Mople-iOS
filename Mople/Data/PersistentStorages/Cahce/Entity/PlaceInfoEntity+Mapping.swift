//
//  PlaceInfoEntity+Mapping.swift
//  Mople
//
//  Created by CatSlave on 12/27/24.
//

import Foundation
import RealmSwift

class PlaceInfoEntity: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var searchDate: Date = Date()
    @Persisted var title: String?
    @Persisted var distance: Int?
    @Persisted var address: String?
    @Persisted var roadAddress: String?
    @Persisted var longitude: Double?
    @Persisted var latitude: Double?
    
    var id: String {
        self._id.stringValue
    }
}

extension PlaceInfoEntity {
    convenience init(_ placeInfo: PlaceInfo) {
        self.init()
        self.title = placeInfo.title
        self.distance = placeInfo.distance
        self.address = placeInfo.address
        self.roadAddress = placeInfo.roadAddress
        self.longitude = placeInfo.longitude
        self.latitude = placeInfo.latitude
    }
}

extension PlaceInfoEntity {
    func toDomain() -> PlaceInfo {
        PlaceInfo(
            uuid: id,
            title: title,
            distance: distance,
            address: address,
            roadAddress: roadAddress,
            longitude: longitude,
            latitude: latitude
        )
    }
}

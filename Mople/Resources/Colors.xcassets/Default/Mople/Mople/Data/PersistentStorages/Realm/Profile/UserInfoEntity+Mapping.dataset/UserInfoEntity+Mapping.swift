//
//  UserInfoEntity+Mapping.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation
import RealmSwift

class UserInfoEntity: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var userId: Int?
    @Persisted var notifyCount: Int = 0
    @Persisted var name: String?
    @Persisted var imagePath: String?
    @Persisted var longitude: Double?
    @Persisted var latitude: Double?
    
    var id: String {
        self._id.stringValue
    }
}

extension UserInfoEntity {
    convenience init(_ userInfo: UserInfo) {
        self.init()
        self.userId = userInfo.id
        self.name = userInfo.name
        self.imagePath = userInfo.imagePath
        self.notifyCount = userInfo.notifyCount
    }
}

extension UserInfoEntity {
    func toDomain() -> UserInfo {
        return .init(id: userId,
                     notifyCount: notifyCount,
                     name: name,
                     imagePath: imagePath)
    }
    
    func updateLocation(longitude: Double,
                        latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    func updateProfile(_ profile: UserInfo) {
        self.name = profile.name
        self.imagePath = profile.imagePath
    }
}


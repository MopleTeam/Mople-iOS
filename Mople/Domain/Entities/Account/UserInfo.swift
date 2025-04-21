//
//  File.swift
//  Group
//
//  Created by CatSlave on 11/6/24.
//

import Foundation

struct UserInfo: Hashable, Equatable {
    let id: Int?
    var notifyCount: Int = 0
    var name: String?
    var imagePath: String?
    var location: Location?
}

extension UserInfo {
    mutating func updateProfile(_ profile: UserInfo) {
        self.name = profile.name
        self.imagePath = profile.imagePath
    }
}

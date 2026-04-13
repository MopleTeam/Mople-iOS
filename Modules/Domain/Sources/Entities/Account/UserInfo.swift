//
//  File.swift
//  Group
//
//  Created by CatSlave on 11/6/24.
//

import Foundation

public struct UserInfo: Hashable, Equatable {
    public let id: Int?
    public var hasNotify: Bool = false
    public var name: String?
    public var imagePath: String?
    public var location: Location?

    public init(id: Int? = nil, hasNotify: Bool = false, name: String? = nil, imagePath: String? = nil, location: Location? = nil) {
        self.id = id
        self.hasNotify = hasNotify
        self.name = name
        self.imagePath = imagePath
        self.location = location
    }
}

public extension UserInfo {
    public mutating func updateProfile(_ profile: UserInfo) {
        self.name = profile.name
        self.imagePath = profile.imagePath
    }
}

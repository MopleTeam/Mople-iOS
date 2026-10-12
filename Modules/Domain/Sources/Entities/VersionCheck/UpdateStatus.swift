//
//  VersionCheck.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

import Foundation

public struct UpdateStatus: Decodable {
    public let forceUpdate: Bool
    public let minVersion: String
    public let message: String

    public init(forceUpdate: Bool, minVersion: String, message: String) {
        self.forceUpdate = forceUpdate
        self.minVersion = minVersion
        self.message = message
    }
}

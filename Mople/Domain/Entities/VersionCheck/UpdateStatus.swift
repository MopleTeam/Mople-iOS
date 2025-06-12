//
//  VersionCheck.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

import Foundation

struct UpdateStatus: Decodable {
    let forceUpdate: Bool
    let minVersion: String
    let message: String
}

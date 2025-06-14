//
//  ForceUpdateChecking.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

import Foundation

struct UpdateStatusResponse: Decodable {
    let forceUpdate: Bool
    let minVersion: String
    let message: String
}

extension UpdateStatusResponse {
    func toDomain() -> UpdateStatus {
        return .init(forceUpdate: forceUpdate,
                     minVersion: minVersion,
                     message: message)
    }
}

//
//  NotifyPayload.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import Foundation

struct NotifyPayloadResponse: Decodable {
    let title: String?
    let message: String?
}

extension NotifyPayloadResponse {
    func toDomain() -> NotifyPayload {
        return .init(title: title,
                     message: message)
    }
}

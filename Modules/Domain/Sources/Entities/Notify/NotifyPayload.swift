//
//  NotifyPayload.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import Foundation

public struct NotifyPayload {
    public let title: String?
    public let message: String?

    public init(title: String? = nil, message: String? = nil) {
        self.title = title
        self.message = message
    }
}

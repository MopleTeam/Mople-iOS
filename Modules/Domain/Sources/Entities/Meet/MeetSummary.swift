//
//  MeetingSummary.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

public struct MeetSummary: Hashable {
    public let id: Int?
    public var name: String?
    public var imagePath: String?

    public init(id: Int? = nil, name: String? = nil, imagePath: String? = nil) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
    }
}

//
//  ReviewImage.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import Foundation

public struct ReviewImage: Equatable {
    public var id: Int?
    public var path: String?

    public init(id: Int? = nil, path: String? = nil) {
        self.id = id
        self.path = path
    }
}

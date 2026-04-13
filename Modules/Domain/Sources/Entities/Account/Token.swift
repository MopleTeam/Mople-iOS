//
//  Token.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

public struct Token: Codable {
    public var accessToken: String?
    public var refreshToken: String?

    public init(accessToken: String? = nil, refreshToken: String? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

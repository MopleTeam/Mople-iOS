//
//  UserToken.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import Foundation

struct TokenInfo: Codable {
    var accessToken: String?
    var refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
    }
}

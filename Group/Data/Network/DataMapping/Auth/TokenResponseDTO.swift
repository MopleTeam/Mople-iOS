//
//  UserToken.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import Foundation

struct TokenResponseDTO: Decodable {
    var accessToken: String?
    var refreshToken: String?
        
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
    }
}

extension TokenResponseDTO {
    func toDomain() -> Token {
        return .init(accessToken: accessToken,
                     refreshToken: refreshToken)
    }
}

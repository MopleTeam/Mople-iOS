//
//  LoginResult.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import Foundation

struct SocialInfo: Encodable {
    let provider: String
    let token: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case provider = "socialProvider"
        case token = "providerToken"
        case email
    }
}

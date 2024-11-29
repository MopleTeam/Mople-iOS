//
//  LoginResult.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import Foundation

struct SocialAccountInfo: Encodable {
    let platform: String
    let identityCode: String
    let email: String
}

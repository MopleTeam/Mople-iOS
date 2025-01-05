//
//  SignUpRequest.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation

struct SignUpRequest: Encodable {
    let socialProvider: String
    let providerToken: String
    let email: String
    let nickname: String
    let deviceType: String = "IOS"
    var image: String?
}

extension SignUpRequest {
    init(social: SocialInfo,
         nickname: String,
         imagePath: String?) {
        self.socialProvider = social.provider
        self.providerToken = social.token
        self.email = social.email
        self.nickname = nickname
        self.image = imagePath
    }
}

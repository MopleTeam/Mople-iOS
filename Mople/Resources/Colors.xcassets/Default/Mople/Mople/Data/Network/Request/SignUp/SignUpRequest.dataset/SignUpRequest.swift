//
//  SignUpRequest.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation

struct SignUpRequest: Encodable {
    var socialProvider: String?
    var providerToken: String?
    var email: String?
    var nickname: String?
    var image: String?
    let deviceType: String = "IOS"
}

extension SignUpRequest {
    init(provider: SocialInfo) {
        self.providerToken = provider.token
        self.socialProvider = provider.provider
        self.providerToken = provider.token
        self.email = provider.email
    }
}

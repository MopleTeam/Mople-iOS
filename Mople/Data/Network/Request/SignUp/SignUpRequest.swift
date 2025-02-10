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
    var nickname: String? {
        didSet {
            print(#function, #line, "닉네임 인풋 : \(nickname)" )
        }
    }
    let deviceType: String = "IOS"
    var image: String?
}

extension SignUpRequest {
    init(provider: SocialInfo) {
        self.providerToken = provider.token
        self.socialProvider = provider.provider
        self.providerToken = provider.token
        self.email = provider.email
    }
}

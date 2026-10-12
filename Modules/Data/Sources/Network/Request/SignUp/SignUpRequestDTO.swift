//
//  SignUpRequestDTO.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation
import Domain

// MARK: - 회원가입 API 요청 DTO
struct SignUpRequestDTO: Encodable {
    var socialProvider: String?
    var providerToken: String?
    var email: String?
    var nickname: String?
    var image: String?
    let deviceType: String = "IOS"
}

// MARK: - Domain → DTO 변환
extension SignUpRequestDTO {
    init(request: SignUpRequest) {
        self.socialProvider = request.socialProvider
        self.providerToken = request.providerToken
        self.email = request.email
        self.nickname = request.nickname
        self.image = request.image
    }
}

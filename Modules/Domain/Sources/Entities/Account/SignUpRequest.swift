//
//  SignUpRequest.swift
//  Domain
//
//  회원가입 요청 모델 — Presentation에서 조립, UseCase/Repo를 거쳐 Data로 전달

import Foundation

/// 회원가입 시 필요한 데이터
public struct SignUpRequest {
    public var socialProvider: String?
    public var providerToken: String?
    public var email: String?
    public var nickname: String?
    public var image: String?

    public init(socialProvider: String? = nil,
                providerToken: String? = nil,
                email: String? = nil,
                nickname: String? = nil,
                image: String? = nil) {
        self.socialProvider = socialProvider
        self.providerToken = providerToken
        self.email = email
        self.nickname = nickname
        self.image = image
    }
}

// MARK: - SocialInfo → SignUpRequest 편의 이니셜라이저
extension SignUpRequest {
    public init(provider: SocialInfo) {
        self.socialProvider = provider.provider
        self.providerToken = provider.token
        self.email = provider.email
    }
}

//
//  SocialInfo.swift
//  Domain
//
//  소셜 로그인 결과 — 플랫폼, 토큰, 이메일을 담는 순수 모델

import Foundation

/// 소셜 로그인 결과를 담는 Domain 모델
/// SocialLoginService.login() 반환값으로 사용
public struct SocialInfo {
    public let provider: String
    public let token: String
    public let email: String

    public init(provider: String, token: String, email: String) {
        self.provider = provider
        self.token = token
        self.email = email
    }
}

//
//  SocialLoginService.swift
//  Mople
//
//  Created by CatSlave on 4/10/26.
//

import Foundation

/// 소셜 로그인 서비스 — Domain에서 정의, Infrastructure에서 구현
/// AppleLoginService, KakaoLoginService 등이 이 프로토콜을 채택
protocol SocialLoginService {
    func login() async throws -> SocialInfo
}

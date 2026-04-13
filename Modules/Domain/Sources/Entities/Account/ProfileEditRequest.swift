//
//  ProfileEditRequest.swift
//  Domain
//
//  프로필 수정 요청 모델

import Foundation

/// 프로필 수정 시 필요한 데이터
public struct ProfileEditRequest {
    public var image: String?
    public var nickname: String?

    public init(image: String? = nil, nickname: String? = nil) {
        self.image = image
        self.nickname = nickname
    }

    /// 기존 UserInfo에서 프로필 수정 요청 모델 생성
    public init(profile: UserInfo) {
        self.image = profile.imagePath
        self.nickname = profile.name
    }
}

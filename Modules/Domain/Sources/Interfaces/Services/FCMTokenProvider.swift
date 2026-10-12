//
//  FCMTokenProvider.swift
//  Domain
//
//  FCM 토큰 제공 프로토콜 — Firebase 의존 없이 토큰 관리
//

import Foundation

/// Domain에서 FCM 토큰에 접근하기 위한 추상화 프로토콜
/// Infrastructure에서 FirebaseMessaging 기반으로 구현한다
public protocol FCMTokenProvider {
    /// 현재 디바이스의 FCM 토큰
    var currentToken: String? { get }
    /// 마지막으로 서버에 업로드한 토큰
    var lastUploadedToken: String? { get }
    /// 토큰 업로드 완료 시 로컬에 저장
    func markAsUploaded(_ token: String)
}

//
//  DefaultFCMTokenProvider.swift
//  Mople
//
//  FCMTokenProvider 구현체 — FirebaseMessaging 기반 토큰 관리
//

import Foundation
import Domain
import FirebaseMessaging

/// Firebase SDK를 통해 FCM 토큰을 제공하고, UserDefaults로 업로드 이력을 관리한다
final class DefaultFCMTokenProvider: FCMTokenProvider {

    var currentToken: String? {
        Messaging.messaging().fcmToken
    }

    var lastUploadedToken: String? {
        UserDefaults.getFCMToken()
    }

    func markAsUploaded(_ token: String) {
        UserDefaults.saveFCMToken(token)
    }
}

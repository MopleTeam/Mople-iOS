//
//  FCMTokenManager.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import FirebaseMessaging

protocol UploadFCMToken {
    func execute() async throws
}

final class UploadFCMTokenUseCase: UploadFCMToken {

    private let repo: FCMTokenUploadRepo


    init(repo: FCMTokenUploadRepo) {
        self.repo = repo
    }

    func execute() async throws {
        guard let currentToken = Messaging.messaging().fcmToken else {
            return
        }

        if let lastUploadToken = UserDefaults.getFCMToken(),
           currentToken == lastUploadToken {
            return
        }

        try await repo.uploadFCMToken(currentToken)
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockUploadFCMTokenUseCase: UploadFCMToken {

    func execute() async throws {
        print("✅ [Mock] FCM 토큰 업로드 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] FCM 토큰 업로드 성공")
    }
}
#endif

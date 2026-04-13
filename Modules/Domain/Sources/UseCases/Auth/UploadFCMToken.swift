//
//  FCMTokenManager.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import Foundation

public protocol UploadFCMToken {
    func execute() async throws
}

// FCM 토큰을 서버에 업로드하는 UseCase
// Firebase 직접 의존 없이 FCMTokenProvider 프로토콜을 통해 토큰에 접근한다
public final class UploadFCMTokenUseCase: UploadFCMToken {

    private let repo: FCMTokenUploadRepo
    private let tokenProvider: FCMTokenProvider

    public init(repo: FCMTokenUploadRepo,
                tokenProvider: FCMTokenProvider) {
        self.repo = repo
        self.tokenProvider = tokenProvider
    }

    public func execute() async throws {
        guard let currentToken = tokenProvider.currentToken else {
            return
        }

        if let lastUploadToken = tokenProvider.lastUploadedToken,
           currentToken == lastUploadToken {
            return
        }

        try await repo.uploadFCMToken(currentToken)
        tokenProvider.markAsUploaded(currentToken)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockUploadFCMTokenUseCase: UploadFCMToken {
    public init() {}

    public func execute() async throws {
        print("✅ [Mock] FCM 토큰 업로드 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] FCM 토큰 업로드 성공")
    }
}
#endif

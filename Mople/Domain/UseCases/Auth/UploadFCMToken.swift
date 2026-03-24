//
//  FCMTokenManager.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import RxSwift
import FirebaseMessaging

protocol UploadFCMToken {
    func execute() -> Observable<Void>
}

final class UploadFCMTokenUseCase: UploadFCMToken {
        
    private let repo: FCMTokenUploadRepo
    
    
    init(repo: FCMTokenUploadRepo) {
        self.repo = repo
    }
    
    func execute() -> Observable<Void> {
        guard let currentToken = Messaging.messaging().fcmToken else {
            return .just(())
        }

        if let lastUploadToken = UserDefaults.getFCMToken(),
           currentToken == lastUploadToken {
            return .just(())
        }

        return repo.uploadFCMToken(currentToken)
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockUploadFCMTokenUseCase: UploadFCMToken {

    func execute() -> Observable<Void> {
        print("✅ [Mock] FCM 토큰 업로드 요청")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print("✅ [Mock] FCM 토큰 업로드 성공") })
    }
}
#endif

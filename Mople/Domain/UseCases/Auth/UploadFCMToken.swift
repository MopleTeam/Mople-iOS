//
//  FCMTokenManager.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import RxSwift
import FirebaseMessaging

protocol UploadFCMToken {
    func executeWhenLogin()
}

final class UploadFCMTokenUseCase: NSObject ,UploadFCMToken, MessagingDelegate {
    private let repo: FCMTokenUploadRepo
    
    init(repo: FCMTokenUploadRepo) {
        self.repo = repo
        super.init()
        Messaging.messaging().delegate = self
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print(#function, #line, "Path : # 토큰 ")
        guard let fcmToken else { return }
        
        // 저장 토큰이 있다면 현재 토큰과 비교
        if let saveToken = UserDefaults.getFCMToken(),
           saveToken == fcmToken {
            return
        }
        repo.uploadFCMToken(fcmToken)
    }
    
    func executeWhenLogin() {
        guard let currentToken = Messaging.messaging().fcmToken else {
            return
        }
        repo.uploadFCMToken(currentToken)
    }
}





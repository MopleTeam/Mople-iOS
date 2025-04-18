//
//  FCMTokenManager.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import Foundation
import FirebaseMessaging


final class FCMTokenManager: NSObject, MessagingDelegate {
    
    private let repo: FCMTokenUploadRepo
    
    init(repo: FCMTokenUploadRepo,
         isLogin: Bool) {
        self.repo = repo
        super.init()
        Messaging.messaging().delegate = self
        uploadTokenWhenLogin(isLogin)
    }
    
    // 디바이스 토큰의 변경사항 시 호출
    // 앱 실행 시 토큰 유효성 비교 후 호출
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print(#function, #line, "Path : # 토큰 ")
        guard let fcmToken else { return }
        
        // 저장 토큰이 있다면 현재 토큰과 비교
        if let saveToken = UserDefaults.getFCMToken(),
           saveToken == fcmToken {
            return
        }
        UserDefaults.saveFCMToken(fcmToken)
        repo.uploadFCMToken(fcmToken)
    }
    
    // 로그인 플랫폼 전환 시에는 didReceiveRegistrationToken가 호출되지 않음
    // 자체적으로 업로드
    func uploadTokenWhenLogin(_ isLogin: Bool) {
        guard isLogin,
              let currentToken = Messaging.messaging().fcmToken else { return }
        print(#function, #line, "Path : # 토큰 ")
        repo.uploadFCMToken(currentToken)
    }
}





//
//  FCMTokenManager.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import Foundation
import FirebaseMessaging

final class FCMTokenManager: NSObject, MessagingDelegate {
    private let repo: FcmTokenUploadRepo
    
    init(repo: FcmTokenUploadRepo) {
        self.repo = repo
        super.init()
        Messaging.messaging().delegate = self
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        print(#function, #line, "# 30 fcm 토큰 : \(fcmToken)" )
        repo.uploadFCMToken(fcmToken)
    }
}





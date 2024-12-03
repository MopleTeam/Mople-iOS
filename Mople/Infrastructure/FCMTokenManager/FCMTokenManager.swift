//
//  FCMTokenManager.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import Foundation
import FirebaseMessaging

protocol RefreshFCMToken {
    func refreshFCMToken()
}

final class FCMTokenManager: NSObject, MessagingDelegate, RefreshFCMToken {
    private let repo: FCMTokenUploadRepo
    
    init(repo: FCMTokenUploadRepo) {
        self.repo = repo
        super.init()
        Messaging.messaging().delegate = self
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print(#function, #line, "# 30 자동 업로드" )
        guard let fcmToken else { return }
        
        repo.uploadFCMToken(fcmToken)
    }
    
    func refreshFCMToken() {
        repo.uploadFCMToken(nil)
    }
}





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
    private var lastUploadedToken: String?
    
    init(repo: FCMTokenUploadRepo,
         isRefresh: Bool) {
        self.repo = repo
        super.init()
        Messaging.messaging().delegate = self
        refreshFCMToken(isRefresh: isRefresh)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        uploadTokenIfNeeded(fcmToken)
    }
    
    func refreshFCMToken(isRefresh: Bool) {
        guard isRefresh,
              let currentToken = Messaging.messaging().fcmToken else { return }
        uploadTokenIfNeeded(currentToken)
    }
    
    private func uploadTokenIfNeeded(_ token: String) {
        print(#function, #line, "토큰 업로드 : \(token), 기존 토큰: \(lastUploadedToken ?? "")" )
        guard token != lastUploadedToken else { return }
        self.lastUploadedToken = token
        repo.uploadFCMToken(token)
    }
}





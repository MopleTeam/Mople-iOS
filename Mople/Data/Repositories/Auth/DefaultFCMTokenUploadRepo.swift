//
//  DefaultFCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import RxSwift
import FirebaseMessaging

final class DefaultFCMTokenRepo: BaseRepositories, FCMTokenUploadRepo {
    
    var disposeBag = DisposeBag()
    
    func uploadFCMToken(_ token: String? = nil) {
        let fcmToken = token ?? Messaging.messaging().fcmToken
        
        requsetUploadToken(fcmToken)
    }
    
    private func requsetUploadToken(_ token: String?) {
        guard let token else { return }
        networkService.authenticatedRequest {
            try APIEndpoints.uploadFCMToken(token)
        }
        .subscribe()
        .disposed(by: disposeBag)
    }
}

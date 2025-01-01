//
//  DefaultFCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import RxSwift
import FirebaseMessaging

final class DefaultFCMTokenRepo: FCMTokenUploadRepo {
    
    var disposeBag = DisposeBag()
    
    private let networkService: AppNetworkService
    
    init(networkService: AppNetworkService) {
        self.networkService = networkService
    }
    
    func uploadFCMToken(_ token: String? = nil) {
        let fcmToken = token ?? Messaging.messaging().fcmToken
        
        requsetUploadToken(fcmToken)
    }
    
    private func requsetUploadToken(_ token: String?) {
        networkService.authenticatedRequest {
            try APIEndpoints.uploadFCMToken(token)
        }
        .debug("# 30 업로드 토큰 : \(token ?? "토큰없음")")
        .subscribe()
        .disposed(by: disposeBag)
    }
}

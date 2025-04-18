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
    
    func uploadFCMToken(_ token: String) {
        print(#function, #line, "FCM 토큰 업로드 : \(token)" )
        requsetUploadToken(token)
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

//디바이스 토큰 확인 7d78e02635931ea890ac5f8c205d7fe9eb04f57749cf1a380ade9d3f7aa5ff57
//uploadFCMToken(_:) 16 FCM 토큰 업로드 : fXf5wuKAoET8oDhgBhIHRn:APA91bFWJQgGL-SK3sGrKEyqKh9nCWjaq8l1_7cW3_SZrwg4xdAphaoPL9QtbSs-87RlKmp5PHSjGF7gBGYRaQyP0rw71DtvqpaiD9cMHBMdMoki_zD61Xw
//
//uploadFCMToken(_:) 16 FCM 토큰 업로드 : fXf5wuKAoET8oDhgBhIHRn:APA91bFWJQgGL-SK3sGrKEyqKh9nCWjaq8l1_7cW3_SZrwg4xdAphaoPL9QtbSs-87RlKmp5PHSjGF7gBGYRaQyP0rw71DtvqpaiD9cMHBMdMoki_zD61Xw
//디바이스 토큰 확인 7d78e02635931ea890ac5f8c205d7fe9eb04f57749cf1a380ade9d3f7aa5ff57

//uploadFCMToken(_:) 16 FCM 토큰 업로드 : fXf5wuKAoET8oDhgBhIHRn:APA91bFWJQgGL-SK3sGrKEyqKh9nCWjaq8l1_7cW3_SZrwg4xdAphaoPL9QtbSs-87RlKmp5PHSjGF7gBGYRaQyP0rw71DtvqpaiD9cMHBMdMoki_zD61Xw
//디바이스 토큰 확인 7d78e02635931ea890ac5f8c205d7fe9eb04f57749cf1a380ade9d3f7aa5ff57

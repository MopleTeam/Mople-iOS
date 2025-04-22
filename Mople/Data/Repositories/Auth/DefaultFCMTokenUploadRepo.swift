//
//  DefaultFCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import RxSwift
import FirebaseMessaging

final class DefaultFCMTokenRepo: BaseRepositories, FCMTokenUploadRepo {
    
    private var disposeBag = DisposeBag()
        
    func uploadFCMToken(_ token: String) {
        print(#function, #line, "Path : # 토큰 업데이트 ")
        let uploadFCMToken = networkService.authenticatedRequest {
            try APIEndpoints.uploadFCMToken(token)
        }
        
        uploadFCMToken
            .flatMap { _ in
                UserDefaults.saveFCMToken(token)
                return .just(())
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}


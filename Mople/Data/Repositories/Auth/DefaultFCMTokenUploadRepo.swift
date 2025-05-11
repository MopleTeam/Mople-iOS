//
//  DefaultFCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import Foundation
import RxSwift

final class DefaultFCMTokenRepo: BaseRepositories, FCMTokenUploadRepo {
        
    func uploadFCMToken(_ token: String) -> Single<Void> {
        return networkService.authenticatedRequest {
            try APIEndpoints.uploadFCMToken(token)
        }
        .do(onSuccess: {
            print(#function, #line, "Path : # 토큰 업데이트 완료 ")
            UserDefaults.saveFCMToken(token)
        })
    }
}


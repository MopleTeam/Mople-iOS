//
//  DefaultFCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import Foundation
import RxSwift

final class DefaultFCMTokenRepo: FcmTokenUploadRepo {
    
    var disposeBag = DisposeBag()
    
    private let networkService: AppNetWorkService
    
    init(networkService: AppNetWorkService) {
        self.networkService = networkService
    }
    
    func uploadFCMToken(_ token: String) {
        print(#function, #line, "# 30 업로드 요청" )
        networkService.authenticatedRequest {
            try APIEndpoints.uploadFCMToken(token)
        }
        .retry(2)
        .debug("# 30")
        .subscribe(onSuccess: { _ in
            print(#function, #line, "# FCMToken 업로드 성공: \(token)" )
        })
        .disposed(by: disposeBag)
        
        
    }
}

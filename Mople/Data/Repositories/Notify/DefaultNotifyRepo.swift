//
//  DefaultNotifyRepo.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import RxSwift

final class DefaultNotifyRepo: BaseRepositories, NotifyRepo {
    func fetchNotifyList() -> Single<[NotifyResponse]> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchNotify()
        }
    }
    
    func resetNotifyCount() -> Single<Void> {
        let resetCount = networkService.authenticatedRequest {
            try APIEndpoints.resetNotifyCount()
        }
        
        return resetCount
            .observe(on: MainScheduler.instance)
            .flatMap({
                print(#function, #line, "Path : # 리셋 요청 ")
                UserInfoStorage.shared.resetNotifyCount()
                return .just(())
            })
    }
}

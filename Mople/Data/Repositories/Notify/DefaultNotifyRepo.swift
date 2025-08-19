//
//  DefaultNotifyRepo.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import RxSwift

final class DefaultNotifyRepo: BaseRepositories, NotifyRepo {
    func fetchNotifyList(cursor: String?) -> Single<PageResponse<NotifyResponse>> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchNotify(cursor: cursor)
        }
    }
    
    func resetNotifyCount() -> Single<Void> {
        let resetCount = networkService.authenticatedRequest {
            try APIEndpoints.resetNotifyCount()
        }
        
        return resetCount
            .observe(on: MainScheduler.instance)
            .flatMap({
                UserInfoStorage.shared.resetNotifyCount()
                return .just(())
            })
    }
}

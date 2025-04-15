//
//  DefaultNotifiSubscribeRepo.swift
//  Mople
//
//  Created by CatSlave on 4/14/25.
//

import RxSwift

final class DefaultNotifySubscribeRepo: BaseRepositories, NotifySubscribeRepo {
    func fetchNotifyState() -> Single<[String]> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchNotifyState()
        }
    }
    
    func subscribeNotify(type: SubscribeType, isSubscribe: Bool) -> Single<Void> {
        return networkService.authenticatedRequest {
            try APIEndpoints.subscribeMeetNotify(type: type,
                                                 isSubscribe: isSubscribe)
        }
    }
}
    
    

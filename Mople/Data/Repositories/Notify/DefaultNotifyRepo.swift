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
}

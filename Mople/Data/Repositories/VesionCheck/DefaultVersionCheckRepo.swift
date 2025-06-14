//
//  DefaultVersionCheckRepo.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

import RxSwift

final class DefaultAppVersionRepo: BaseRepositories, AppVersionRepo {
    func checkForceUpdate() -> Single<UpdateStatusResponse> {
        let endpoint = APIEndpoints.checkAppVersionUpdate()
        return networkService.basicRequest(endpoint: endpoint)
    }
}

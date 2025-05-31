//
//  BaseRepositories.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

class BaseRepositories: LifeCycleLoggable {
    private(set) var networkService: AppNetworkService
    
    init(networkService: AppNetworkService) {
        self.networkService = networkService
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
}

//
//  BaseRepositories.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Domain

public class BaseRepositories: LifeCycleLoggable {
    private(set) var networkService: AppNetworkService

    public init(networkService: AppNetworkService) {
        self.networkService = networkService
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
}

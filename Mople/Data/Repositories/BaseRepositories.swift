//
//  BaseRepositories.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

class BaseRepositories {
    private(set) var networkService: AppNetworkService
    
    init(networkService: AppNetworkService) {
        print(#function, #line, "LifeCycle Test \(String(describing: Self.self)) Created" )
        self.networkService = networkService
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test \(String(describing: Self.self)) Deinit" )
    }
}

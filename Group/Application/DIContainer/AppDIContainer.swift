//
//  AppDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import Foundation

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    lazy var apiDataTransferService: DataTransferService = {
        
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfiguration.apiBaseURL))
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    
    lazy var appleLoginService = DefaultAppleLoginService()
    
    lazy var tokenKeychainService = TokenKeyChain()
    
    func makeLoginSceneDIContainer() -> LoginSceneDIContainer {
        return LoginSceneDIContainer(apiDataTransferService: apiDataTransferService,
                                     appleLoginService: appleLoginService,
                                     tokenKeyChainService: tokenKeychainService)
    }
}



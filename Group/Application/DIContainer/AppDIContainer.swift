//
//  AppDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import Foundation

final class AppDIContainer {
    
    // MARK: - 로그인이 된 상태인지 체크
    var hasToken: Bool {
        return tokenKeychainService.hasToken()
    }
    
    // MARK: - 앱 서비스
    lazy var appConfiguration = AppConfiguration()
    
    lazy var apiDataTransferService: DataTransferService = {
        
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfiguration.apiBaseURL))
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    
    lazy var appleLoginService = DefaultAppleLoginService()
    
    #warning("Mock")
    lazy var tokenKeychainService = KeyChainServiceMock()
}

// MARK: - Make DIContainer
extension AppDIContainer {
    
    // MARK: - 로그인 플로우
        func makeLoginSceneDIContainer() -> LoginSceneDIContainer {
        return LoginSceneDIContainer(apiDataTransferService: apiDataTransferService,
                                     appleLoginService: appleLoginService,
                                     tokenKeyChainService: tokenKeychainService)
    }
    
    // MARK: - 메인 플로우
    func makeMainSceneDIContainer() -> MainSceneDIContainer {
        return MainSceneDIContainer(apiDataTransferService: apiDataTransferService,
                                    tokenKeyChainService: tokenKeychainService)
    }
}



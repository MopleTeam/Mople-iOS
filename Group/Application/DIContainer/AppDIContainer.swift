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
    
    lazy var tokenKeychainService = KeyChainServiceImpl()
}

// MARK: - Make DIContainer
extension AppDIContainer {
    
    // MARK: - 로그인
    func makeLoginSceneDIContainer() -> LoginSceneDIContainer {
        return LoginSceneDIContainer(apiDataTransferService: apiDataTransferService,
                                     appleLoginService: appleLoginService,
                                     tokenKeyChainService: tokenKeychainService)
    }
    
    func makeMainSceneDIContainer() -> MainSceneDIContainer {
        return MainSceneDIContainer(apiDataTransferService: apiDataTransferService)
    }
    
    // MARK: - 메인
    func makeHomeSceneDIContainer() -> HomeSceneDIContainer {
        return HomeSceneDIContainer(apiDataTransferService: apiDataTransferService)
    }
    
    // MARK: - 모임 리스트
    func makeGroupListSceneDIContainer() -> GroupListSceneDIContainer {
        return GroupListSceneDIContainer(apiDataTransferService: apiDataTransferService)
    }
    
    // MARK: - 캘린더
    func makeCalendarSceneDIContainer() -> CalendarSceneDIContainer {
        return CalendarSceneDIContainer(apiDataTransferService: apiDataTransferService)
    }
    
    // MARK: - 프로필
    func makeProfileSceneDIContainer() -> ProfileSceneDIContainer {
        return ProfileSceneDIContainer(apiDataTransferService: apiDataTransferService)
    }
}



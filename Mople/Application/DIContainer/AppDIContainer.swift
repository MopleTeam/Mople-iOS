//
//  AppDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import Foundation

class BaseContainer: LifeCycleLoggable {
    let appNetworkService: AppNetworkService
    let commonViewFactory: ViewDependencies
    
    init(appNetworkService: AppNetworkService,
         commonFactory: ViewDependencies) {
        self.appNetworkService = appNetworkService
        self.commonViewFactory = commonFactory
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
}

final class AppDIContainer {
    
    // MARK: - 앱 서비스
    
    lazy var appNetworkService: AppNetworkService = {
        
        let baseUrl = AppConfiguration.apiBaseURL
        
        let config = ApiDataNetworkConfig(
            baseURL: URL(string: baseUrl),
            headers: AppConfiguration.Network.defaultHeaders
        )
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        
        let transferService = DefaultDataTransferService(with: apiDataNetwork)
        
        return DefaultAppNetWorkService(dataTransferService: transferService)
    }()
    
    lazy var commonDIContainer = ViewDIContainer(appNetworkService: appNetworkService)
}

// MARK: - Make DIContainer
extension AppDIContainer {
    
    // MARK: - 런치 스크린
    func makeLaunchViewController(coordinator: LaunchCoordination) -> LaunchViewController {
        return LaunchViewController(
            screenName: ScreenName.splash,
            viewModel: makeLaunchViewModel(coordinator: coordinator))
    }
    
    private func makeLaunchViewModel(coordinator: LaunchCoordination) -> LaunchViewModel {
        let fetchUserRepo = DefaultUserInfoRepo(networkService: appNetworkService)
        return DefaultLaunchViewModel(fetchUserInfoUseCase: makeFetchUserInfoUseCase(repo: fetchUserRepo),
                                      checkAppVersionUseCase: makeCheckAppVersionUseCase(),
                                      coordinator: coordinator)
    }
    
    private func makeFetchUserInfoUseCase(repo: UserInfoRepo) -> FetchUserInfo {
        #if DEV
        let useCase = MockDataManager.resolve(FetchUserInfoUseCase(userInfoRepo: repo) as FetchUserInfo, mock: MockFetchUserInfoUseCase())
        #else
        let useCase = FetchUserInfoUseCase(userInfoRepo: repo)
        #endif
        return useCase
    }
    
    private func makeCheckAppVersionUseCase() -> CheckVersion {
        let repo = DefaultAppVersionRepo(networkService: appNetworkService)
        #if DEV
        let useCase = MockDataManager.resolve(CheckVersionUseCase(repo: repo) as CheckVersion, mock: MockCheckVersionUseCase())
        #else
        let useCase = CheckVersionUseCase(repo: repo)
        #endif
        return useCase
    }

    // MARK: - 로그인 플로우
    func makeLoginSceneDIContainer() -> AuthSceneDIContainer {
        return AuthSceneDIContainer(appNetworkService: appNetworkService,
                                     commonFactory: commonDIContainer)
    }
    
    // MARK: - 메인 플로우
    func makeMainSceneDIContainer(isLoign: Bool) -> MainSceneDIContainer {
        return MainSceneDIContainer(isLogin: isLoign,
                                    appNetworkService: appNetworkService,
                                    commonFactory: commonDIContainer)
    }
}




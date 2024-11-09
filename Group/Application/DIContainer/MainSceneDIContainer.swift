//
//  MainSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

protocol TabBarCoordinaotorDependencies {
    func makeTabBarController() -> UITabBarController
    func getMainFlowCoordinator() -> [BaseCoordinator]
}

final class MainSceneDIContainer: TabBarCoordinaotorDependencies {
    
    let appNetworkService: AppNetWorkService
    
    init(appNetworkService: AppNetWorkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeMainFlowCoordinator(navigationController: UINavigationController) -> TabBarCoordinator {
        let flow = TabBarCoordinator(navigationController: navigationController,
                                     dependencies: self)
        return flow
    }
}

extension MainSceneDIContainer {
    func makeTabBarController() -> UITabBarController {
        return MainTabBarController()
    }
    
    func getMainFlowCoordinator() -> [BaseCoordinator] {
        return [makeHomeCoordinator(),
                makeGroupListCoordinator(),
                makeCalendarCoordinator(),
                makeProfileCoordinator()]
    }
}

extension MainSceneDIContainer {
    // MARK: - 홈
    private func makeHomeCoordinator() -> BaseCoordinator {
        let homeDI = HomeSceneDIContainer(appNetworkService: appNetworkService)
        let navigationController = MainNavigationController()
        navigationController.tabBarItem = .init(title: "홈",
                                                image: .home,
                                                selectedImage: nil)
          
        return homeDI.makeHomeFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 모임 리스트
    private func makeGroupListCoordinator() -> BaseCoordinator {
        let groupDI = GroupListSceneDIContainer(appNetworkService: appNetworkService)
        
        let navigationController = MainNavigationController()
        navigationController.tabBarItem = .init(title: "모임",
                                                image: .people,
                                                selectedImage: nil)
        
        return groupDI.makeGroupListFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 캘린더
    private func makeCalendarCoordinator() -> BaseCoordinator {
        let calendarDI = CalendarSceneDIContainer(appNetworkService: appNetworkService)
        
        let navigationController = MainNavigationController()
        navigationController.tabBarItem = .init(title: "일정관리",
                                                image: .tabBarCalendar,
                                                selectedImage: nil)
        
        return calendarDI.makeCalendarFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 프로필
    private func makeProfileCoordinator() -> BaseCoordinator {
        let profileDI = SetupSceneDIContainer(appNetworkService: appNetworkService)
        
        let navigationController = MainNavigationController()
        navigationController.tabBarItem = .init(title: "프로필",
                                                image: .person,
                                                selectedImage: nil)
        
        return profileDI.makeSetupFlowCoordinator(navigationController: navigationController)
    }
}

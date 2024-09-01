//
//  MainSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

final class MainSceneDIContainer: TabBarCoordinaotorDependencies {
    
    let apiDataTransferService: DataTransferService
    
    private lazy var groupRepository: GroupRepository = .init(dataTransferService: apiDataTransferService)
    
    init(apiDataTransferService: DataTransferService) {
        self.apiDataTransferService = apiDataTransferService
    }
    
    func makeMainFlowCoordinator(navigationController: UINavigationController) -> TabBarCoordinator {
        let flow = TabBarCoordinator(navigationController: navigationController,
                                     dependencies: self)
        return flow
    }
}

extension MainSceneDIContainer {
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
        let homeDI = HomeSceneDIContainer(apiDataTransferService: apiDataTransferService)
        
        let navigationController = UINavigationController()

        navigationController.tabBarItem = .init(title: "홈",
                                                image: UIImage(systemName: "house.fill"),
                                                selectedImage: nil)
          
        return homeDI.makeHomeFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 모임 리스트
    private func makeGroupListCoordinator() -> BaseCoordinator {
        let groupDI = GroupListSceneDIContainer(apiDataTransferService: apiDataTransferService)
        
        let navigationController = UINavigationController()
        navigationController.tabBarItem = .init(title: "모임",
                                                image: UIImage(systemName: "list.bullet"),
                                                selectedImage: nil)
        
        return groupDI.makeGroupListFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 캘린더
    private func makeCalendarCoordinator() -> BaseCoordinator {
        let calendarDI = CalendarSceneDIContainer(apiDataTransferService: apiDataTransferService)
        
        let navigationController = UINavigationController()
        navigationController.tabBarItem = .init(title: "홈",
                                                image: UIImage(systemName: "calendar"),
                                                selectedImage: nil)
        
        return calendarDI.makeCalendarFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 프로필
    private func makeProfileCoordinator() -> BaseCoordinator {
        let profileDI = ProfileSceneDIContainer(apiDataTransferService: apiDataTransferService)
        
        let navigationController = UINavigationController()
        navigationController.tabBarItem = .init(title: "홈",
                                                image: UIImage(systemName: "person.crop.circle"),
                                                selectedImage: nil)
        
        return profileDI.makeProfileFlowCoordinator(navigationController: navigationController)
    }
}

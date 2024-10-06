//
//  MainSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

final class MainSceneDIContainer: TabBarCoordinaotorDependencies {
    
    let apiDataTransferService: DataTransferService
    let tokenKeyChainService: KeyChainService
    
    private lazy var groupRepository: GroupRepository = .init(dataTransferService: apiDataTransferService,
                                                              tokenKeyCahinService: tokenKeyChainService)
    
    init(apiDataTransferService: DataTransferService,
         tokenKeyChainService: KeyChainService) {
        self.apiDataTransferService = apiDataTransferService
        self.tokenKeyChainService = tokenKeyChainService
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
//        UIImage(systemName: "newspaper")?.withAlignmentRectInsets(UIEdgeInsets(top: 8.5, left: 0, bottom: -8.5, right: 0)), tag: 0)
        let navigationController = UINavigationController()
        navigationController.tabBarItem = .init(title: "홈",
                                                image: .home,
                                                selectedImage: nil)
          
        return homeDI.makeHomeFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 모임 리스트
    private func makeGroupListCoordinator() -> BaseCoordinator {
        let groupDI = GroupListSceneDIContainer(apiDataTransferService: apiDataTransferService)
        
        let navigationController = UINavigationController()
        navigationController.tabBarItem = .init(title: "모임",
                                                image: .people,
                                                selectedImage: nil)
        
        return groupDI.makeGroupListFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 캘린더
    private func makeCalendarCoordinator() -> BaseCoordinator {
        let calendarDI = CalendarSceneDIContainer(apiDataTransferService: apiDataTransferService)
        
        let navigationController = UINavigationController()
        navigationController.tabBarItem = .init(title: "일정관리",
                                                image: .tabBarCalendar,
                                                selectedImage: nil)
        
        return calendarDI.makeCalendarFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 프로필
    private func makeProfileCoordinator() -> BaseCoordinator {
        let profileDI = ProfileSceneDIContainer(apiDataTransferService: apiDataTransferService)
        
        let navigationController = UINavigationController()
        navigationController.tabBarItem = .init(title: "프로필",
                                                image: .person,
                                                selectedImage: nil)
        
        return profileDI.makeProfileFlowCoordinator(navigationController: navigationController)
    }
}

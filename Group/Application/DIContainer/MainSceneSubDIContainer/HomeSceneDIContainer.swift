//
//  HomeSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

final class HomeSceneDIContainer: HomeCoordinatorDependencies {
    
    let apiDataTransferService: DataTransferService

    init(apiDataTransferService: DataTransferService) {
        self.apiDataTransferService = apiDataTransferService
    }
    
    func makeHomeFlowCoordinator(navigationController: UINavigationController) -> HomeCoordinator {
        let flow = HomeCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
    
    func makeHomeViewController() -> HomeViewController {
        return HomeViewController(reactor: makeHomeViewReactor())
    }
    
    func makeHomeViewReactor() -> ScheduleViewReactor {
        return ScheduleViewReactor(fetchUseCase: fetchRecentScheduleMock())
    }
}

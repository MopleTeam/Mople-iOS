//
//  HomeSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

final class HomeSceneDIContainer: HomeCoordinatorDependencies {
    
    let appNetworkService: AppNetWorkService

    init(appNetworkService: AppNetWorkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeHomeFlowCoordinator(navigationController: UINavigationController) -> HomeCoordinator {
        let flow = HomeCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
    
    func makeHomeViewController(action: HomeViewAction) -> HomeViewController {
        return HomeViewController(reactor: makeHomeViewReactor(action))
    }
    
    private func makeHomeViewReactor(_ action: HomeViewAction) -> ScheduleViewReactor {
        return ScheduleViewReactor(fetchRecentSchedule: FetchRecentScheduleMock(),
                                   viewAction: action)
    }
}

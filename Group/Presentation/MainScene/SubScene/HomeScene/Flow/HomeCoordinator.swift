//
//  MainFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol HomeCoordinatorDependencies {
    func makeHomeViewController(action: HomeViewAction) -> HomeViewController
}

final class HomeCoordinator: BaseCoordinator {
    
    private let dependencies: HomeCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: HomeCoordinatorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let action = HomeViewAction(logOut: logOut,
                                    presentNextEvent: presentNextEvent(lastRecentDate:))
        
        let vc = dependencies.makeHomeViewController(action: action)
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func logOut() {
        (self.parentCoordinator as? SignOut)?.singOut()
    }
    
    private func presentNextEvent(lastRecentDate: Date) {
        (self.parentCoordinator as? KeepTabBarNavigation)?.pushCalendarView(lastRecentDate: lastRecentDate)
    }
}

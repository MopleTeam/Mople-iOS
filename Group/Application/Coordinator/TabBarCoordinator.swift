//
//  TapBarCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol TabBarCoordinaotorDependencies {
    func getMainFlowCoordinator() -> [BaseCoordinator]
}

final class TabBarCoordinator: BaseCoordinator {
    
    private let dependencies: TabBarCoordinaotorDependencies
    private let tabBarController: UITabBarController
 
    init(navigationController: UINavigationController,
         dependencies: TabBarCoordinaotorDependencies) {
        self.dependencies = dependencies
        self.tabBarController = UITabBarController()
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let coordinators = dependencies.getMainFlowCoordinator()
        coordinators.forEach { self.start(coordinator: $0) }
        let viewControllers = coordinators.map { $0.navigationController }
        tabBarController.setViewControllers(viewControllers, animated: true)
        navigationController.pushViewController(tabBarController, animated: true)
    }
}


//
//  MainFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol HomeCoordinatorDependencies {
    func makeHomeViewController() -> HomeViewController
}

final class HomeCoordinator: BaseCoordinator {
    
    private let dependencies: HomeCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: HomeCoordinatorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = dependencies.makeHomeViewController()
        
        navigationController.pushViewController(vc, animated: true)
    }
}

//
//  GroupListFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol GroupListCoordinatorDependencies {
    func makeGroupListViewController() -> GroupListViewController
}

final class GroupListCoordinator: BaseCoordinator {
    private let dependencies: GroupListCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: GroupListCoordinatorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = dependencies.makeGroupListViewController()
        
        navigationController.pushViewController(vc, animated: true)
    }
}

//
//  ProfileFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol ProfileCoordinatorDependencies {
    func makeProfileViewController() -> ProfileViewController
}

final class ProfileCoordinator: BaseCoordinator {
    private let dependencies: ProfileCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: ProfileCoordinatorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = dependencies.makeProfileViewController()
        
        navigationController.pushViewController(vc, animated: true)
    }
}

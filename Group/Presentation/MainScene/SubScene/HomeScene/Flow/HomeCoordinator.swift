//
//  MainFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol HomeCoordinatorDependencies {
    func makeHomeViewController(action: LogOutAction) -> HomeViewController
}

final class HomeCoordinator: BaseCoordinator {
    
    private let dependencies: HomeCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: HomeCoordinatorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let action = LogOutAction(logOut: logOut)
        let vc = dependencies.makeHomeViewController(action: action)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func logOut() {
        (self.parentCoordinator as? SignOut)?.singOut()
    }
}

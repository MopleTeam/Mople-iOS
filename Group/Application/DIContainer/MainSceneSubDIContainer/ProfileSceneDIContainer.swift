//
//  ProfileSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

final class ProfileSceneDIContainer: ProfileCoordinatorDependencies {
 
    let apiDataTransferService: DataTransferService

    init(apiDataTransferService: DataTransferService) {
        self.apiDataTransferService = apiDataTransferService
    }
    
    func makeProfileFlowCoordinator(navigationController: UINavigationController) -> ProfileCoordinator {
        let flow = ProfileCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
    
    func makeProfileViewController() -> ProfileViewController {
        return ProfileViewController()
    }
}

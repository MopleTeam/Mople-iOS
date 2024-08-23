//
//  AppCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit

final class AppFlowCoordinator: BaseCoordinator {
    
    
    private let appDIContainer: AppDIContainer
 
    init(navigationController: UINavigationController,
         appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        super.init(navigationController: navigationController)
    }
    
    
    #warning("진입 뷰 조절")
    override func start() {
        let loginSceneDIContainer = appDIContainer.makeLoginSceneDIContainer()
        let flow = loginSceneDIContainer.makeLoginFlowCoordinator(navigationController: navigationController)
        flow.navigationController = navigationController
        flow.start()
    }
    
    
}

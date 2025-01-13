//
//  PlanDetailFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

protocol PlanDetailCoordination: AnyObject {
    func endFlow()
}

final class PlanDetailFlowCoordinator: BaseCoordinator {
    
    private let dependencies: PlanDetailSceneDependencies
    
    init(dependencies: PlanDetailSceneDependencies,
         navigationController: AppNaviViewController) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let planDetailVC = dependencies.makePlanDetailViewController()
        navigationController.pushViewController(planDetailVC, animated: false)
    }
}

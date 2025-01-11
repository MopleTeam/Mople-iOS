//
//  PlanDetailSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

protocol PlanDetailSceneDependencies {
    
}

final class PlanDetailSceneDIContainer: PlanDetailSceneDependencies {
    
    let appNetworkService: AppNetworkService
    
    init(appNetworkService: AppNetworkService) {
        print(#function, #line, "LifeCycle Test PlanDetailSceneDIContainer Created" )
        self.appNetworkService = appNetworkService
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test PlanDetailSceneDIContainer Deinit" )
    }
    
    func makePlanDetailCoordinator(navigationController: UINavigationController) -> PlanDetailFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: navigationController)
    }
    
    
}

final class PlanDetailFlowCoordinator: BaseCoordinator {
    
    private let dependencies: PlanDetailSceneDependencies
    
    init(dependencies: PlanDetailSceneDependencies,
         navigationController: UINavigationController) {
        print(#function, #line, "LifeCycle Test PlanDetailFlowCoordinator Created" )

        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test PlanDetailFlowCoordinator Deinit" )
    }
}

//
//  PlanDetailSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

protocol PlanDetailSceneDependencies {
    func makePlanDetailViewController() -> PlanDetailViewController
}

final class PlanDetailSceneDIContainer: PlanDetailSceneDependencies {
    
    private let appNetworkService: AppNetworkService
    private let plan: Plan
    
    init(appNetworkService: AppNetworkService,
         plan: Plan) {
        self.appNetworkService = appNetworkService
        self.plan = plan
    }
    
    func makePlanDetailCoordinator() -> PlanDetailFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
    }
}

extension PlanDetailSceneDIContainer {
    func makePlanDetailViewController() -> PlanDetailViewController {
        return .init(reactor: makePlanDetailViewReactor(),
                     title: "약속 상세")
    }
    
    func makePlanDetailViewReactor() -> PlanDetailViewReactor {
        return .init(plan: plan)
    }
}


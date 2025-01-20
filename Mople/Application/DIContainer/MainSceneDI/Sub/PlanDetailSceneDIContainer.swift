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
    private let planId: Int
    
    init(appNetworkService: AppNetworkService,
         planId: Int) {
        self.appNetworkService = appNetworkService
        self.planId = planId
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
        return .init(planId: planId,
                     fetchPlanDetailUseCase: makeFetchPlanDetailUsecase())
    }
    
    func makeFetchPlanDetailUsecase() -> FetchPlanDetail {
        return FetchPlanDetailUseCase(planRepo: makePlanDetailRepo())
    }
    
    func makePlanDetailRepo() -> PlanQueryRepo {
        return DefaultPlanQueryRepo(networkService: appNetworkService)
    }
}


//
//  PlanCreateSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import UIKit

protocol PlanCreateSceneContainer {
    func makePlanCreateFlowCoordinator(navigationController: UINavigationController) -> BaseCoordinator
}

protocol PlanCreateSceneDependencies {
    func makePlanCreateViewController(flow: PlanCreateFlow) -> PlanCreateViewController
    func makeGroupSelectViewController() -> GroupSelectViewController
    func makeDateSelectViewController() -> PlanDateSelectViewController
    func makeTimeSelectViewController() -> PlanTimePickerViewController
    
    func makeSearchLocationDIContainer() -> SearchLocationSceneContainer
}

final class PlanCreateSceneDIContainer: PlanCreateSceneDependencies & PlanCreateSceneContainer {

    private let appNetworkService: AppNetworkService
    private var commonReactor: PlanCreateViewReactor?
    
    init(appNetworkService: AppNetworkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makePlanCreateFlowCoordinator(navigationController: UINavigationController) -> BaseCoordinator {
        return PlanCreateFlowCoordinator(navigationController: navigationController,
                                         dependencies: self)
    }
}

extension PlanCreateSceneDIContainer {
    func makeSearchLocationDIContainer() -> SearchLocationSceneContainer {
        return SearchLocationSceneDIContainer(appNetworkService: appNetworkService)
    }
}

extension PlanCreateSceneDIContainer {
    private func makeCommonReactor(flow: PlanCreateFlow) {
        commonReactor = .init(createPlanUseCase: CreatePlanMock(),
                                   fetchMeetListUSeCase: FetchGroupListMock(),
                                   flow: flow)
    }

    func makePlanCreateViewController(flow: PlanCreateFlow) -> PlanCreateViewController {
        makeCommonReactor(flow: flow)
        return PlanCreateViewController(title: "일정 생성",
                                        reactor: commonReactor)
    }
    
    func makeGroupSelectViewController() -> GroupSelectViewController {
        return GroupSelectViewController(reactor: commonReactor)
    }
    
    func makeDateSelectViewController() -> PlanDateSelectViewController {
        return PlanDateSelectViewController(reactor: commonReactor)
    }
    
    func makeTimeSelectViewController() -> PlanTimePickerViewController {
        return PlanTimePickerViewController(reactor: commonReactor)
    }
}

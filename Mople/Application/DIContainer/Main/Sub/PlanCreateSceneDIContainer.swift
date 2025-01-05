//
//  PlanCreateSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import UIKit

protocol PlanCreateSceneDependencies {
    func makePlanCreateViewController(coordinator: PlanCreateCoordination) -> PlanCreateViewController
    func makeGroupSelectViewController() -> MeetSelectViewController
    func makeDateSelectViewController() -> PlanDateSelectViewController
    func makeTimeSelectViewController() -> PlanTimePickerViewController
    func makeSearchLocationDIContainer() -> SearchLocationSceneContainer
}

final class PlanCreateSceneDIContainer: PlanCreateSceneDependencies {

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
    private func makeCommonReactor(coordinator: PlanCreateCoordination) {
        commonReactor = .init(createPlanUseCase: CreatePlanMock(),
                              fetchMeetListUSeCase: FetchGroupListMock(),
                              coordinator: coordinator)
    }

    func makePlanCreateViewController(coordinator: PlanCreateCoordination) -> PlanCreateViewController {
        makeCommonReactor(coordinator: coordinator)
        return PlanCreateViewController(title: "일정 생성",
                                        reactor: commonReactor)
    }
    
    func makeGroupSelectViewController() -> MeetSelectViewController {
        return MeetSelectViewController(reactor: commonReactor)
    }
    
    func makeDateSelectViewController() -> PlanDateSelectViewController {
        return PlanDateSelectViewController(reactor: commonReactor)
    }
    
    func makeTimeSelectViewController() -> PlanTimePickerViewController {
        return PlanTimePickerViewController(reactor: commonReactor)
    }
}

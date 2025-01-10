//
//  PlanCreateSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import UIKit

protocol PlanCreateSceneDependencies {
    func makePlanCreateViewController(coordinator: PlanCreateCoordination) -> CreatePlanViewController
    func makeGroupSelectViewController() -> MeetSelectViewController
    func makeDateSelectViewController() -> PlanDateSelectViewController
    func makeTimeSelectViewController() -> PlanTimePickerViewController
    func makeSearchLocationDIContainer() -> SearchLocationSceneContainer
}

final class PlanCreateSceneDIContainer: PlanCreateSceneDependencies {

    private let appNetworkService: AppNetworkService
    private let fetchMeetListUseCase: FetchMeetList
    private var commonReactor: CreatePlanViewReactor?
    
    init(appNetworkService: AppNetworkService,
         fetchMeetListUseCase: FetchMeetList) {
        self.appNetworkService = appNetworkService
        self.fetchMeetListUseCase = fetchMeetListUseCase
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
    func makePlanCreateViewController(coordinator: PlanCreateCoordination) -> CreatePlanViewController {
        makeCommonReactor(coordinator: coordinator)
        return CreatePlanViewController(title: "일정 생성",
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

// MARK: - 공통 ViewModel
extension PlanCreateSceneDIContainer {
    private func makeCommonReactor(coordinator: PlanCreateCoordination) {
        commonReactor = .init(createPlanUseCase: makeCreatePlanUseCase(),
                              fetchMeetListUSeCase: fetchMeetListUseCase,
                              coordinator: coordinator)
    }
    
    private func makeCreatePlanUseCase() -> CreatePlan {
        return CreatePlanUseCase(createPlanRepo: makeCreatePlanRepo())
    }
    
    private func makeCreatePlanRepo() -> CreatePlanRepo {
        return DefaultCreatePlanRepo(networkService: appNetworkService)
    }
}

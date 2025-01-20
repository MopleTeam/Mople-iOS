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
    func makeSearchLocationCoordinator() -> BaseCoordinator
}

final class PlanCreateSceneDIContainer: PlanCreateSceneDependencies {

    private let appNetworkService: AppNetworkService
    private var commonReactor: CreatePlanViewReactor?
    private let meetList: [MeetSummary]
    
    init(appNetworkService: AppNetworkService,
         meetList: [MeetSummary]) {
        self.appNetworkService = appNetworkService
        self.meetList = meetList
    }
    
    func makePlanCreateFlowCoordinator() -> BaseCoordinator {
        return PlanCreateFlowCoordinator(navigationController: AppNaviViewController(),
                                         dependencies: self)
    }
}

extension PlanCreateSceneDIContainer {
    func makeSearchLocationCoordinator() -> BaseCoordinator {
        let searchLoactionDI = SearchLocationSceneDIContainer(appNetworkService: appNetworkService)
        return searchLoactionDI.makeSearchLocationFlowCoordinator()
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
                              meetList: meetList,
                              coordinator: coordinator)
    }
    
    private func makeCreatePlanUseCase() -> CreatePlan {
        return CreatePlanUseCase(createPlanRepo: makeCreatePlanRepo())
    }
    
    private func makeCreatePlanRepo() -> PlanCommandRepo {
        return DefaultPlanCommandRepo(networkService: appNetworkService)
    }
}

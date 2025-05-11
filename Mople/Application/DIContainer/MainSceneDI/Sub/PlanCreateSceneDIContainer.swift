//
//  PlanCreateSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import UIKit

protocol PlanCreateSceneDependencies {
    func makePlanCreateViewController(coordinator: PlanCreateCoordination) -> CreatePlanViewController
    func makeSearchLocationCoordinator() -> BaseCoordinator
}

final class PlanCreateSceneDIContainer: PlanCreateSceneDependencies {

    private let appNetworkService: AppNetworkService
    private var createPlanReactor: CreatePlanViewReactor?
    private let type: PlanCreationType
    
    init(appNetworkService: AppNetworkService,
         type: PlanCreationType) {
        self.appNetworkService = appNetworkService
        self.type = type
    }
    
    func makePlanCreateFlowCoordinator(completionHandler: ((Plan) -> Void)? = nil) -> BaseCoordinator {
        return PlanCreateFlowCoordinator(navigationController: AppNaviViewController(),
                                         dependencies: self,
                                         completionHandler: completionHandler)
    }
}

// MARK: - Default View
extension PlanCreateSceneDIContainer {
    func makePlanCreateViewController(coordinator: PlanCreateCoordination) -> CreatePlanViewController {
        createPlanReactor = makeCreatePlanViewReactor(coordinator: coordinator)
        return CreatePlanViewController(screenName: .plan_write,
                                        title: getViewTitle(),
                                        type: type,
                                        reactor: createPlanReactor!)
    }
    
    private func makeCreatePlanViewReactor(coordinator: PlanCreateCoordination) -> CreatePlanViewReactor {
        return .init(createPlanUseCase: makeCreatePlanUseCase(),
                              editPlanUseCase: makeEditPlanUseCase(),
                              type: type,
                              coordinator: coordinator)
    }
    
    private func makeCreatePlanUseCase() -> CreatePlan {
        return CreatePlanUseCase(createPlanRepo: makeCreatePlanRepo())
    }
    
    private func makeEditPlanUseCase() -> EditPlan {
        return EditPlanUseCase(editPlanRepo: makeCreatePlanRepo())
    }
    
    private func makeCreatePlanRepo() -> PlanRepo {
        return DefaultPlanRepo(networkService: appNetworkService)
    }
}

// MARK: - Flow
extension PlanCreateSceneDIContainer {
    // MARK: - 장소 검색
    func makeSearchLocationCoordinator() -> BaseCoordinator {
        let searchLoactionDI = SearchLocationSceneDIContainer(appNetworkService: appNetworkService,
                                                              delegate: createPlanReactor)
        return searchLoactionDI.makeSearchLocationFlowCoordinator()
    }
}

// MARK: - Helper
extension PlanCreateSceneDIContainer {
    private func getViewTitle() -> String {
        switch type {
        case .newFromMeetList, .newInMeeting:
            return L10n.createPlan
        case .edit:
            return L10n.editPlan
        }
    }
}

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
    func makeDateSelectViewController() -> DateSelectViewController
    func makeTimeSelectViewController() -> TimePickerViewController
    func makeSearchLocationCoordinator() -> BaseCoordinator
}

final class PlanCreateSceneDIContainer: PlanCreateSceneDependencies {

    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    private var commonReactor: CreatePlanViewReactor?
    private let type: PlanCreationType
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory,
         type: PlanCreationType) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
        self.type = type
    }
    
    func makePlanCreateFlowCoordinator(completionHandler: ((Plan) -> Void)? = nil) -> BaseCoordinator {
        return PlanCreateFlowCoordinator(navigationController: AppNaviViewController(),
                                         dependencies: self,
                                         completionHandler: completionHandler)
    }
}

extension PlanCreateSceneDIContainer {
    func makeSearchLocationCoordinator() -> BaseCoordinator {
        let searchLoactionDI = SearchLocationSceneDIContainer(appNetworkService: appNetworkService,
                                                              commonFactory: commonFactory,
                                                              delegate: commonReactor!)
        return searchLoactionDI.makeSearchLocationFlowCoordinator()
    }
}

extension PlanCreateSceneDIContainer {
    func makePlanCreateViewController(coordinator: PlanCreateCoordination) -> CreatePlanViewController {
        makeCommonReactor(coordinator: coordinator)
        return CreatePlanViewController(title: getViewTitle(),
                                        reactor: commonReactor)
    }
    
    func makeGroupSelectViewController() -> MeetSelectViewController {
        return MeetSelectViewController(reactor: commonReactor)
    }
    
    func makeDateSelectViewController() -> DateSelectViewController {
        return DateSelectViewController(reactor: commonReactor)
    }
    
    func makeTimeSelectViewController() -> TimePickerViewController {
        return TimePickerViewController(reactor: commonReactor)
    }
}

// MARK: - 공통 ViewModel
extension PlanCreateSceneDIContainer {
    private func makeCommonReactor(coordinator: PlanCreateCoordination) {
        commonReactor = .init(createPlanUseCase: makeCreatePlanUseCase(),
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

// MARK: - Hpler
extension PlanCreateSceneDIContainer {
    private func getViewTitle() -> String {
        switch type {
        case .create:
            return "일정 생성"
        case .edit:
            return "일정 수정"
        }
    }
}

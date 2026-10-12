//
//  PlanCreateSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import UIKit
import Domain
import Data

protocol PlanCreateSceneDependencies {
    func makePlanCreateViewController(coordinator: PlanCreateCoordination) -> CreatePlanViewController
    func makeSearchLocationCoordinator() -> BaseCoordinator
}

final class PlanCreateSceneDIContainer: BaseContainer, PlanCreateSceneDependencies {

    private var createPlanReactor: CreatePlanViewReactor?
    private let type: PlanCreationType
    
    init(appNetworkService: AppNetworkService,
         commonViewFactory: ViewDependencies,
         userSession: UserSessionProvider,
         type: PlanCreationType) {
        self.type = type
        super.init(appNetworkService: appNetworkService,
                   commonFactory: commonViewFactory,
                   userSession: userSession)
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
                     fetchMeetPageUseCase: makeFetchMeetPageUseCase(),
                     type: type,
                     coordinator: coordinator)
    }
    
    private func makeCreatePlanUseCase() -> CreatePlan {
        #if DEV
        return MockDataManager.resolve(CreatePlanUseCase(createPlanRepo: makeCreatePlanRepo()) as CreatePlan, mock: MockCreatePlanUseCase())
        #else
        return CreatePlanUseCase(createPlanRepo: makeCreatePlanRepo())
        #endif
    }

    private func makeEditPlanUseCase() -> EditPlan {
        #if DEV
        return MockDataManager.resolve(EditPlanUseCase(editPlanRepo: makeCreatePlanRepo()) as EditPlan, mock: MockEditPlanUseCase())
        #else
        return EditPlanUseCase(editPlanRepo: makeCreatePlanRepo())
        #endif
    }

    private func makeFetchMeetPageUseCase() -> FetchMeetPage {
        let repo = DefaultMeetRepo(networkService: appNetworkService)
        #if DEV
        return MockDataManager.resolve(FetchMeetPageUseCase(repo: repo, session: userSession) as FetchMeetPage, mock: MockFetchMeetPageUseCase())
        #else
        return FetchMeetPageUseCase(repo: repo, session: userSession)
        #endif
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
                                                              commonViewFactory: commonViewFactory,
                                                              userSession: userSession,
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

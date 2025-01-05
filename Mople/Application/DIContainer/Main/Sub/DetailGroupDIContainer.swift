//
//  DetailGroupDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol DetailMeetSceneDependencies {
    func makeDetailMeetViewController(coordinator: DetailMeetCoordination) -> DetailMeetViewController
    func makeFutruePlanListViewController() -> FuturePlanListViewController
    func makePastPlanListViewController() -> PastPlanListViewController
}

final class DetailGroupSceneDIContainer: DetailMeetSceneDependencies {

    private let appNetworkService: AppNetworkService
    private let meetId: Int
    
    init(appNetworkService: AppNetworkService,
         meetId: Int) {
        self.appNetworkService = appNetworkService
        self.meetId = meetId
    }
    
    func makeDetailMeetCoordinator(navigationController: UINavigationController) -> DetailMeetSceneCoordinator {
        return .init(dependencies: self,
                     navigationController: navigationController)
    }
}

extension DetailGroupSceneDIContainer {
    func makeDetailMeetViewController(coordinator: DetailMeetCoordination) -> DetailMeetViewController {
        return .init(title: nil,
                     reactor: makeDetailMeetViewReactor(coordinator: coordinator))
    }
    
    private func makeDetailMeetViewReactor(coordinator: DetailMeetCoordination) -> DetailMeetViewReactor {
        return .init(fetchMeetUseCase: fetchMeetUseCaseMock(),
                     coordinator: coordinator,
                     meetID: meetId)
    }
    
    func makeFutruePlanListViewController() -> FuturePlanListViewController {
        return FuturePlanListViewController()
    }
    
    func makePastPlanListViewController() -> PastPlanListViewController {
        return PastPlanListViewController()
    }
}

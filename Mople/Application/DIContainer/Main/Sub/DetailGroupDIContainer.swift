//
//  DetailGroupDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol DetailMeetSceneDependencies {
    func makeDetailMeetViewController(coordinator: DetailMeetCoordination) -> DetailMeetViewController
    func makeFuturePlanListViewController() -> FuturePlanListViewController
    func makePastPlanListViewController() -> PastPlanListViewController
    func makeMeetSetupViewController(meet: Meet,
                                     coordinator: DetailMeetCoordination) -> MeetSetupViewController
}

final class DetailGroupSceneDIContainer: DetailMeetSceneDependencies {

    private let appNetworkService: AppNetworkService
    private let meetId: Int
    private var mainReactor: DetailMeetViewReactor?
    
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
        makeDetailMeetViewReactor(coordinator: coordinator)
        return .init(title: nil, reactor: mainReactor!)
    }
    
    private func makeDetailMeetViewReactor(coordinator: DetailMeetCoordination) {
        self.mainReactor = .init(fetchMeetUseCase: fetchMeetUseCaseMock(),
                     coordinator: coordinator,
                     meetID: meetId)
    }
    
    func makeFuturePlanListViewController() -> FuturePlanListViewController {
        return FuturePlanListViewController(reactor: makeFuturePlanListViewReactor(),
                                            parentReactor: mainReactor!)
    }
    
    private func makeFuturePlanListViewReactor() -> FutruePlanListViewReactor {
        return .init(fetchPlanUseCase: FetchMeetFuturePlanMock(),
                     requestJoinPlanUseCase: RequestJoinPlanMock(),
                     requsetLeavePlanUseCase: RequestLeavePlanMock(),
                     meetID: meetId)
    }
    
    func makePastPlanListViewController() -> PastPlanListViewController {
        return PastPlanListViewController(reactor: makePastPlanListViewReactor(),
                                          parentReactor: mainReactor!)
    }
    
    private func makePastPlanListViewReactor() -> PastPlanListViewReactor {
        return .init(fetchReviewUseCase: FetchReviewMock(),
                     meetID: meetId)
    }
    
    func makeMeetSetupViewController(meet: Meet, coordinator: DetailMeetCoordination) -> MeetSetupViewController {
        return .init(title: "모임 설정",
                     reactor: makeMeetSetupViewReactor(meet: meet, coordinator: coordinator))
    }
    
    private func makeMeetSetupViewReactor(meet: Meet, coordinator: DetailMeetCoordination) -> MeetSetupViewReactor {
        return .init(meet: meet,
                     coordinator: coordinator)
    }
}

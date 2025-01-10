//
//  DetailGroupDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol MeetDetailSceneDependencies {
    func makeMeetDetailViewController(coordinator: MeetDetailCoordination) -> DetailMeetViewController
    func makeFuturePlanListViewController() -> FuturePlanListViewController
    func makePastPlanListViewController() -> PastPlanListViewController
    func makeMeetSetupViewController(meet: Meet,
                                     coordinator: MeetDetailCoordination) -> MeetSetupViewController
}

final class MeetDetailSceneDIContainer: MeetDetailSceneDependencies {

    private let appNetworkService: AppNetworkService
    private let meetId: Int
    private var mainReactor: MeetDetailViewReactor?
    
    init(appNetworkService: AppNetworkService,
         meetId: Int) {
        self.appNetworkService = appNetworkService
        self.meetId = meetId
    }
    
    func makeMeetDetailCoordinator(navigationController: UINavigationController) -> MeetDetailSceneCoordinator {
        return .init(dependencies: self,
                     navigationController: navigationController)
    }
}

extension MeetDetailSceneDIContainer {
    
    // MARK: - Main
    func makeMeetDetailViewController(coordinator: MeetDetailCoordination) -> DetailMeetViewController {
        makeDetailMeetViewReactor(coordinator: coordinator)
        return .init(title: nil, reactor: mainReactor!)
    }
    
    private func makeDetailMeetViewReactor(coordinator: MeetDetailCoordination) {
        self.mainReactor = .init(fetchMeetUseCase: makeFetchMeetDetailUseCase(),
                     coordinator: coordinator,
                     meetID: meetId)
    }
    
    private func makeFetchMeetDetailUseCase() -> FetchMeetDetail {
        return FetchMeetDetailUseCase(meetDetailRepo: makeMeetDetailRepo())
    }
    
    private func makeMeetDetailRepo() -> MeetDetailRepo {
        return DefaultMeetDetailRepo(networkService: appNetworkService)
    }
    
    
    // MARK: - FuturePlanList
    func makeFuturePlanListViewController() -> FuturePlanListViewController {
        return FuturePlanListViewController(reactor: makeFuturePlanListViewReactor(),
                                            parentReactor: mainReactor!)
    }
    
    private func makeFuturePlanListViewReactor() -> FuturePlanListViewReactor {
        return .init(fetchPlanUseCase: makeFetchFuturePlanUsecase(),
                     participationPlanUseCase: makeParticipationPlanUseCase(),
                     meetID: meetId)
    }
    
    private func makeFetchFuturePlanUsecase() -> FetchMeetFuturePlan {
        return FetchMeetFuturePlanUsecase(meetPlanRepo: makeFuturePlanListRepo())
    }
    
    private func makeFuturePlanListRepo() -> MeetPlanListRepo {
        return DefaultMeetPlanListRepo(networkService: appNetworkService)
    }
    
    private func makeParticipationPlanUseCase() -> RequestParticipationPlan {
        return RequestParticipationPlanUseCase(participationRepo: makeParticipationPlanRepo())
    }
    
    private func makeParticipationPlanRepo() -> ParticipationPlanRepo {
        return DefaultParticipationPlanRepo(networkService: appNetworkService)
    }
    
    
    // MARK: - PastPlanList
    func makePastPlanListViewController() -> PastPlanListViewController {
        return PastPlanListViewController(reactor: makePastPlanListViewReactor(),
                                          parentReactor: mainReactor!)
    }
    
    private func makePastPlanListViewReactor() -> PastPlanListViewReactor {
        return .init(fetchReviewUseCase: makeFetchReviewListUsecase(),
                     meetID: meetId)
    }
    
    private func makeFetchReviewListUsecase() -> FetchReviewList {
        return fetchReviewListUseCase(reviewListRepo: makeReviewRepo())
    }
    
    private func makeReviewRepo() -> FetchReviewListRepo {
        return DefaultFetchReviewListRepo(networkService: appNetworkService)
    }
    
    // MARK: - Setup
    func makeMeetSetupViewController(meet: Meet, coordinator: MeetDetailCoordination) -> MeetSetupViewController {
        return .init(title: "모임 설정",
                     reactor: makeMeetSetupViewReactor(meet: meet, coordinator: coordinator))
    }
    
    private func makeMeetSetupViewReactor(meet: Meet, coordinator: MeetDetailCoordination) -> MeetSetupViewReactor {
        return .init(meet: meet,
                     coordinator: coordinator)
    }
}

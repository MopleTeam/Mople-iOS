//
//  DetailGroupDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol MeetDetailSceneDependencies {
    // MARK: - View
    func makeMeetDetailViewController(coordinator: MeetDetailCoordination) -> DetailMeetViewController
    func makeFuturePlanListViewController(coordinator: MeetDetailCoordination) -> FuturePlanListViewController
    func makePastPlanListViewController() -> PastPlanListViewController
    func makeMeetSetupViewController(meet: Meet,
                                     coordinator: MeetDetailCoordination) -> MeetSetupViewController
    
    // MARK: - Flow
    func makePlanDetailFlowCoordinator(plan: Plan) -> BaseCoordinator
}

final class MeetDetailSceneDIContainer: MeetDetailSceneDependencies {
    
    private let meetId: Int

    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    
    private var mainReactor: MeetDetailViewReactor?
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory,
         meetId: Int) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
        self.meetId = meetId
    }
    
    func makeMeetDetailCoordinator() -> MeetDetailSceneCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
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
    
    
    // MARK: - 예정된 일정리스트 뷰
    func makeFuturePlanListViewController(coordinator: MeetDetailCoordination) -> FuturePlanListViewController {
        return FuturePlanListViewController(
            reactor: makeFuturePlanListViewReactor(coordinator: coordinator),
            parentReactor: mainReactor!)
    }
    
    private func makeFuturePlanListViewReactor(coordinator: MeetDetailCoordination) -> FuturePlanListViewReactor {
        return .init(fetchPlanUseCase: makeFetchFuturePlanUsecase(),
                     participationPlanUseCase: makeParticipationPlanUseCase(),
                     coordinator: coordinator,
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
    
    
    // MARK: - 리뷰리스트 뷰
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
    
    // MARK: - 모임 설정 뷰
    func makeMeetSetupViewController(meet: Meet, coordinator: MeetDetailCoordination) -> MeetSetupViewController {
        return .init(title: "모임 설정",
                     reactor: makeMeetSetupViewReactor(meet: meet, coordinator: coordinator))
    }
    
    private func makeMeetSetupViewReactor(meet: Meet, coordinator: MeetDetailCoordination) -> MeetSetupViewReactor {
        return .init(meet: meet,
                     coordinator: coordinator)
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailFlowCoordinator(plan: Plan) -> BaseCoordinator {
        return commonFactory.makePlanDetailCoordinator(plan: plan)
    }
}

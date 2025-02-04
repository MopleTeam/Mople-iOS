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
    func makeMeetPlanListViewController(coordinator: MeetDetailCoordination) -> MeetPlanListViewController
    func makeMeetReviewListViewController(coordinator: MeetDetailCoordination) -> MeetReviewListViewController
    func makeMeetSetupViewController(meet: Meet,
                                     coordinator: MeetSetupCoordination) -> MeetSetupViewController
    
    // MARK: - Flow
    func makePlanDetailFlowCoordinator(postId: Int,
                                       type: PlanDetailType) -> BaseCoordinator
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
        return .init(title: nil, reactor: mainReactor)
    }
    
    private func makeDetailMeetViewReactor(coordinator: MeetDetailCoordination) {
        self.mainReactor = .init(fetchMeetUseCase: makeFetchMeetDetailUseCase(),
                                 coordinator: coordinator,
                                 meetID: meetId)
    }
    
    private func makeFetchMeetDetailUseCase() -> FetchMeetDetail {
        return FetchMeetDetailUseCase(meetDetailRepo: makeMeetDetailRepo())
    }
    
    private func makeMeetDetailRepo() -> MeetQueryRepo {
        return DefaultMeetQueryRepo(networkService: appNetworkService)
    }
    
    
    // MARK: - 예정된 일정리스트 뷰
    func makeMeetPlanListViewController(coordinator: MeetDetailCoordination) -> MeetPlanListViewController {
        return MeetPlanListViewController(
            reactor: makeMeetPlanListViewReactor(coordinator: coordinator),
            parentReactor: mainReactor)
    }
    
    private func makeMeetPlanListViewReactor(coordinator: MeetDetailCoordination) -> MeetPlanListViewReactor {
        return .init(fetchPlanUseCase: makeFetchMeetPlanUsecase(),
                     participationPlanUseCase: makeParticipationPlanUseCase(),
                     coordinator: coordinator,
                     meetID: meetId)
    }
    
    private func makeFetchMeetPlanUsecase() -> FetchMeetPlanList {
        return FetchMeetPlanListUsecase(meetPlanRepo: makeMeetPlanListRepo())
    }
    
    private func makeMeetPlanListRepo() -> PlanQueryRepo {
        return DefaultPlanQueryRepo(networkService: appNetworkService)
    }
    
    private func makeParticipationPlanUseCase() -> RequestParticipationPlan {
        return RequestParticipationPlanUseCase(participationRepo: makeParticipationPlanRepo())
    }
    
    private func makeParticipationPlanRepo() -> PlanCommandRepo {
        return DefaultPlanCommandRepo(networkService: appNetworkService)
    }
    
    // MARK: - 리뷰리스트 뷰
    func makeMeetReviewListViewController(coordinator: MeetDetailCoordination) -> MeetReviewListViewController {
        return MeetReviewListViewController(
            reactor: makeMeetReviewListViewReactor(coordinator: coordinator),
            parentReactor: mainReactor
        )
    }
    
    private func makeMeetReviewListViewReactor(coordinator: MeetDetailCoordination) -> MeetReviewListViewReactor {
        return .init(fetchReviewUseCase: makeFetchReviewListUsecase(),
                     coordinator: coordinator,
                     meetID: meetId)
    }
    
    private func makeFetchReviewListUsecase() -> FetchReviewList {
        return FetchReviewListUseCase(reviewListRepo: makeReviewRepo())
    }
    
    private func makeReviewRepo() -> ReviewQueryRepo {
        return DefaultReviewQueryRepo(networkService: appNetworkService)
    }
    
    // MARK: - 모임 설정 뷰
    func makeMeetSetupViewController(meet: Meet,
                                     coordinator: MeetSetupCoordination) -> MeetSetupViewController {
        return .init(title: "모임 설정",
                     reactor: makeMeetSetupViewReactor(meet: meet,
                                                       coordinator: coordinator))
    }
    
    private func makeMeetSetupViewReactor(meet: Meet,
                                          coordinator: MeetSetupCoordination) -> MeetSetupViewReactor {
        return .init(meet: meet,
                     coordinator: coordinator)
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailFlowCoordinator(postId: Int,
                                       type: PlanDetailType) -> BaseCoordinator {
        print(#function, #line, "#55 : \(type) ")
        return commonFactory.makePlanDetailCoordinator(postId: postId,
                                                       type: type)
    }
}

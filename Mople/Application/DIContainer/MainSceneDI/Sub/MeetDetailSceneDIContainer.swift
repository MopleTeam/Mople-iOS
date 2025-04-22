//
//  DetailGroupDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol MeetDetailSceneDependencies {
    // MARK: - View
    func makeMeetDetailViewController(coordinator: MeetDetailCoordination) -> MeetDetailViewController
    func makeMeetPlanListViewController() -> MeetPlanListViewController
    func makeMeetReviewListViewController(coordinator: MeetDetailCoordination) -> MeetReviewListViewController
    func makeMeetSetupViewController(meet: Meet,
                                     coordinator: MeetSetupCoordination) -> MeetSetupViewController
    func makeEditMeetViewController(previousMeet: Meet,
                                    coordinator: MeetCreateViewCoordination) -> CreateMeetViewController
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController
    
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
    func makeMeetDetailViewController(coordinator: MeetDetailCoordination) -> MeetDetailViewController {
        makeDetailMeetViewReactor(coordinator: coordinator)
        return .init(title: nil, reactor: mainReactor)
    }
    
    private func makeDetailMeetViewReactor(coordinator: MeetDetailCoordination) {
        self.mainReactor = .init(fetchMeetUseCase: makeFetchMeetDetailUseCase(),
                                 coordinator: coordinator,
                                 meetID: meetId)
    }
    
    private func makeFetchMeetDetailUseCase() -> FetchMeetDetail {
        let repo = DefaultMeetRepo(networkService: appNetworkService)
        return FetchMeetDetailUseCase(repo: repo)
    }
    
    
    // MARK: - 예정된 일정리스트 뷰
    func makeMeetPlanListViewController() -> MeetPlanListViewController {
        return MeetPlanListViewController(
            reactor: makeMeetPlanListViewReactor()
        )
    }
    
    private func makeMeetPlanListViewReactor() -> MeetPlanListViewReactor {
        let reactor = MeetPlanListViewReactor(fetchPlanUseCase: makeFetchMeetPlanUsecase(),
                                              participationPlanUseCase: makeParticipationPlanUseCase(),
                                              delegate: mainReactor!,
                                              meetId: meetId)
        mainReactor?.planListCommands = reactor
        return reactor
    }
    
    private func makeFetchMeetPlanUsecase() -> FetchMeetPlanList {
        let repo = DefaultPlanRepo(networkService: appNetworkService)
        return FetchMeetPlanListUsecase(repo: repo)
    }
    
    private func makeParticipationPlanUseCase() -> ParticipationPlan {
        return ParticipationPlanUseCase(participationRepo: makeParticipationPlanRepo())
    }
    
    private func makeParticipationPlanRepo() -> PlanRepo {
        return DefaultPlanRepo(networkService: appNetworkService)
    }
    
    // MARK: - 리뷰리스트 뷰
    func makeMeetReviewListViewController(coordinator: MeetDetailCoordination) -> MeetReviewListViewController {
        return MeetReviewListViewController(
            reactor: makeMeetReviewListViewReactor(coordinator: coordinator))
    }
    
    private func makeMeetReviewListViewReactor(coordinator: MeetDetailCoordination) -> MeetReviewListViewReactor {
        let reactor = MeetReviewListViewReactor(fetchReviewUseCase: makeFetchReviewListUsecase(),
                                                coordinator: coordinator,
                                                delegate: mainReactor!,
                                                meetId: meetId)
        mainReactor?.reviewListCommands = reactor
        return reactor
    }
    
    private func makeFetchReviewListUsecase() -> FetchReviewList {
        let repo = DefaultReviewRepo(networkService: appNetworkService)
        return FetchReviewListUseCase(repo: repo)
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
                     deleteMeetUseCase: makeDeleteMeetUseCase(),
                     coordinator: coordinator)
    }
    
    private func makeDeleteMeetUseCase() -> DeleteMeet {
        return DeleteMeetUseCase(
            repo: DefaultMeetRepo(networkService: appNetworkService)
        )
    }
    
    // MARK: - 모임 수정 뷰
    func makeEditMeetViewController(previousMeet: Meet, coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return commonFactory.makeCreateMeetViewController(isFlow: true,
                                                          isEdit: true,
                                                          type: .edit(previousMeet),
                                                          coordinator: coordinator)
    }
    
    // MARK: - 멤버 리스트 뷰
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController {
        return commonFactory.makeMemberListViewController(type: .meet(id: meetId),
                                                          coordinator: coordinator)
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailFlowCoordinator(postId: Int,
                                       type: PlanDetailType) -> BaseCoordinator {
        return commonFactory.makePlanDetailCoordinator(postId: postId,
                                                       type: type)
    }
}

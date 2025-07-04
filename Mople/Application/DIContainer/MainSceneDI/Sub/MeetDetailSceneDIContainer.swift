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
    func makeMeetReviewListViewController() -> MeetReviewListViewController
    func makeMeetSetupViewController(meet: Meet,
                                     coordinator: MeetSetupCoordination) -> MeetSetupViewController
    func makeEditMeetViewController(previousMeet: Meet,
                                    coordinator: MeetCreateViewCoordination) -> CreateMeetViewController
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController
    func makeMeetImageViewController(imagePath: String?,
                                     title: String?,
                                     coordinator: NavigationCloseable) -> PhotoBookViewController
    
    // MARK: - Flow
    func makePlanCreateFlowCoordinator(meet: MeetSummary,
                                       completion: ((Plan) -> Void)?) -> BaseCoordinator
    
    func makePostDetailFlowCoordinator(postId: Int,
                                       type: PostType) -> BaseCoordinator
}

final class MeetDetailSceneDIContainer: BaseContainer, MeetDetailSceneDependencies {
    
    // MARK: - Variables
    private let meetId: Int
    private let isJoin: Bool

    private var mainReactor: MeetDetailViewReactor?
    
    init(appNetworkService: AppNetworkService,
         commonFactory: ViewDependencies,
         meetId: Int,
         isJoin: Bool) {
        self.meetId = meetId
        self.isJoin = isJoin
        super.init(appNetworkService: appNetworkService,
                   commonFactory: commonFactory)
    }
    
    func makeMeetDetailCoordinator() -> MeetDetailSceneCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
    }
}

// MARK: - Default View
extension MeetDetailSceneDIContainer {
    
    // MARK: - 메인
    func makeMeetDetailViewController(coordinator: MeetDetailCoordination) -> MeetDetailViewController {
        makeDetailMeetViewReactor(coordinator: coordinator)
        return .init(screenName: .meet_detail,
                     title: nil,
                     reactor: mainReactor)
    }
    
    private func makeDetailMeetViewReactor(coordinator: MeetDetailCoordination) {
        let meetRepo = DefaultMeetRepo(networkService: appNetworkService)
        self.mainReactor = .init(fetchMeetUseCase: makeFetchMeetDetailUseCase(repo: meetRepo),
                                 inviteMeetUseCase: makeInviteMeetUseCase(repo: meetRepo),
                                 coordinator: coordinator,
                                 meetID: meetId)
    }
    
    private func makeFetchMeetDetailUseCase(repo: MeetRepo) -> FetchMeetDetail {
        return FetchMeetDetailUseCase(repo: repo)
    }
    
    private func makeInviteMeetUseCase(repo: MeetRepo) -> InviteMeet {
        return InviteMeetUseCase(repo: repo)
    }
    
    
    // MARK: - 일정 리스트
    func makeMeetPlanListViewController() -> MeetPlanListViewController {
        return MeetPlanListViewController(
            reactor: makeMeetPlanListViewReactor()
        )
    }
    
    private func makeMeetPlanListViewReactor() -> MeetPlanListViewReactor {
        let repo = DefaultPlanRepo(networkService: appNetworkService)
        let reactor = MeetPlanListViewReactor(fetchPlanUseCase: makeFetchMeetPlanUsecase(repo: repo),
                                              participationPlanUseCase: makeParticipationPlanUseCase(repo: repo),
                                              delegate: mainReactor!,
                                              meetId: meetId)
        mainReactor?.planListCommands = reactor
        return reactor
    }
    
    private func makeFetchMeetPlanUsecase(repo: PlanRepo) -> FetchMeetPlanList {
        return FetchMeetPlanListUsecase(repo: repo)
    }
    
    private func makeParticipationPlanUseCase(repo: PlanRepo) -> ParticipationPlan {
        return ParticipationPlanUseCase(participationRepo: repo)
    }
    
    // MARK: - 리뷰 리스트
    func makeMeetReviewListViewController() -> MeetReviewListViewController {
        return MeetReviewListViewController(
            reactor: makeMeetReviewListViewReactor())
    }
    
    private func makeMeetReviewListViewReactor() -> MeetReviewListViewReactor {
        let reactor = MeetReviewListViewReactor(fetchReviewUseCase: makeFetchReviewListUsecase(),
                                                delegate: mainReactor!,
                                                meetId: meetId,
                                                isJoin: isJoin)
        mainReactor?.reviewListCommands = reactor
        return reactor
    }
    
    private func makeFetchReviewListUsecase() -> FetchMeetReviewList {
        let repo = DefaultReviewRepo(networkService: appNetworkService)
        return FetchMeetReviewListUseCase(repo: repo)
    }
}

// MARK: - View
extension MeetDetailSceneDIContainer {
    // MARK: - 모임 설정 뷰
    func makeMeetSetupViewController(meet: Meet,
                                     coordinator: MeetSetupCoordination) -> MeetSetupViewController {
        return .init(screenName: .meet_setting,
                     title: L10n.Meetdetail.setup,
                     reactor: makeMeetSetupViewReactor(meet: meet,
                                                       coordinator: coordinator))
    }
    
    private func makeMeetSetupViewReactor(meet: Meet,
                                          coordinator: MeetSetupCoordination) -> MeetSetupViewReactor {
        let repo = DefaultMeetRepo(networkService: appNetworkService)
        return .init(meet: meet,
                     deleteMeetUseCase: makeDeleteMeetUseCase(repo: repo),
                     coordinator: coordinator)
    }
    
    private func makeDeleteMeetUseCase(repo: MeetRepo) -> DeleteMeet {
        return DeleteMeetUseCase(repo: repo)
    }
    
    // MARK: - 모임 수정 뷰
    func makeEditMeetViewController(previousMeet: Meet, coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return commonViewFactory.makeCreateMeetViewController(isFlow: true,
                                                          isEdit: true,
                                                          type: .edit(previousMeet),
                                                          coordinator: coordinator)
    }
    
    // MARK: - 멤버 리스트 뷰
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController {
        return commonViewFactory.makeMemberListViewController(type: .meet(id: meetId),
                                                          coordinator: coordinator)
    }
    
    // MARK: - 포토뷰
    func makeMeetImageViewController(imagePath: String?,
                                     title: String?,
                                     coordinator: NavigationCloseable) -> PhotoBookViewController {
        let imagePaths = [imagePath].compactMap { $0 }
        return commonViewFactory.makePhotoViewController(title: title,
                                                         imagePath: imagePaths,
                                                         defaultImageType: .meet,
                                                         coordinator: coordinator)
    }
}

// MARK: - Flow
extension MeetDetailSceneDIContainer {
    
    // MARK: - 일정 생성
    func makePlanCreateFlowCoordinator(meet: MeetSummary, completion: ((Plan) -> Void)?) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            commonViewFactory: commonViewFactory,
            type: .newInMeeting(meet))
        return planCreateDI.makePlanCreateFlowCoordinator(completionHandler: completion)
    }
    
    // MARK: - 포스트 상세
    func makePostDetailFlowCoordinator(postId: Int,
                                       type: PostType) -> BaseCoordinator {
        let planDetailDI = PostDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonViewFactory,
                                                      type: type,
                                                      id: postId)
        return planDetailDI.makePostDetailCoordinator()
    }
}

//
//  DetailGroupDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit
import SwiftUI

protocol MeetDetailSceneDependencies {
    // MARK: - View
    func makeMeetDetailViewController(coordinator: MeetDetailCoordination) -> MeetDetailViewController
    func makeMeetPlanListViewController() -> MeetPlanListViewController
    func makeMeetReviewListViewController() -> MeetReviewListViewController
    func makeMeetSetupViewController(meet: Meet,
                                     coordinator: MeetSetupCoordination) -> MeetSetupViewController
    func makeTransferMeetViewController(meet: Meet) -> UIViewController
    func makeEditMeetViewController(previousMeet: Meet,
                                    coordinator: MeetCreateViewCoordination) -> CreateMeetViewController
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController
    func makeMeetImageViewController(imagePath: String?,
                                     title: String?) -> PhotoBookViewController
    
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
         userSession: UserSessionProvider,
         meetId: Int,
         isJoin: Bool) {
        self.meetId = meetId
        self.isJoin = isJoin
        super.init(appNetworkService: appNetworkService,
                   commonFactory: commonFactory,
                   userSession: userSession)
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
        #if DEV
        return MockDataManager.resolve(FetchMeetDetailUseCase(repo: repo) as FetchMeetDetail, mock: MockFetchMeetDetailUseCase())
        #else
        return FetchMeetDetailUseCase(repo: repo)
        #endif
    }
    
    private func makeInviteMeetUseCase(repo: MeetRepo) -> InviteMeet {
        #if DEV
        return MockDataManager.resolve(InviteMeetUseCase(repo: repo) as InviteMeet, mock: MockInviteMeetUseCase())
        #else
        return InviteMeetUseCase(repo: repo)
        #endif
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
    
    private func makeFetchMeetPlanUsecase(repo: PlanRepo) -> FetchPlanPage {
        #if DEV
        return MockDataManager.resolve(FetchPlanPageUsecase(repo: repo, session: userSession) as FetchPlanPage, mock: MockFetchPlanPageUseCase())
        #else
        return FetchPlanPageUsecase(repo: repo, session: userSession)
        #endif
    }
    
    private func makeParticipationPlanUseCase(repo: PlanRepo) -> ParticipationPlan {
        #if DEV
        return MockDataManager.resolve(ParticipationPlanUseCase(participationRepo: repo) as ParticipationPlan, mock: MockParticipationPlanUseCase())
        #else
        return ParticipationPlanUseCase(participationRepo: repo)
        #endif
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
        #if DEV
        return MockDataManager.resolve(FetchMeetReviewListUseCase(repo: repo, session: userSession) as FetchMeetReviewList, mock: MockFetchMeetReviewListUseCase())
        #else
        return FetchMeetReviewListUseCase(repo: repo, session: userSession)
        #endif
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
        #if DEV
        return MockDataManager.resolve(DeleteMeetUseCase(repo: repo) as DeleteMeet, mock: MockDeleteMeetUseCase())
        #else
        return DeleteMeetUseCase(repo: repo)
        #endif
    }
    
    // MARK: - 모임 수정 뷰
    func makeEditMeetViewController(previousMeet: Meet, coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return commonViewFactory.makeCreateMeetViewController(isFlow: true,
                                                          isEdit: true,
                                                          type: .edit(previousMeet),
                                                          coordinator: coordinator)
    }
    
    // MARK: - 모임 양도하기 뷰 (SwiftUI + Combine + RxCombine)
    @MainActor func makeTransferMeetViewController(meet: Meet) -> UIViewController {
        let viewModel = makeTransferMeetViewModel(meet: meet)
        let swiftUIView = TransferMeetView(viewModel: viewModel)
        return UIHostingController(rootView: swiftUIView)
    }
    
    @MainActor private func makeTransferMeetViewModel(meet: Meet) -> TransferMeetViewModel {
        let fetchMemberListUseCase = makeFetchMemberListUseCase()
        let transferUseCase = makeTransferMeetUseCase()
        return TransferMeetViewModel(
            meet: meet,
            fetchMemberListUseCase: fetchMemberListUseCase,
            transferUseCase: transferUseCase
        )
    }
    
    private func makeFetchMemberListUseCase() -> FetchMemberList {
        let memberRepo = DefaultMemberRepo(networkService: appNetworkService)
        #if DEV
        return MockDataManager.resolve(FetchMemberUseCase(memberListRepo: memberRepo) as FetchMemberList, mock: MockFetchMemberUseCase())
        #else
        return FetchMemberUseCase(memberListRepo: memberRepo)
        #endif
    }

    private func makeTransferMeetUseCase() -> TransferMeet {
        let repo = DefaultMeetRepo(networkService: appNetworkService)
        #if DEV
        return MockDataManager.resolve(TransferMeetUseCase(repo: repo) as TransferMeet, mock: MockTransferMeetUseCase())
        #else
        return TransferMeetUseCase(repo: repo)
        #endif
    }

    // MARK: - 멤버 리스트 뷰
    func makeMemberListViewController(coordinator: MemberListViewCoordination) -> MemberListViewController {
        return commonViewFactory.makeMemberListViewController(type: .meet(id: meetId),
                                                          coordinator: coordinator)
    }
    
    // MARK: - 포토뷰
    func makeMeetImageViewController(imagePath: String?,
                                     title: String?) -> PhotoBookViewController {
        let imagePaths = [imagePath].compactMap { $0 }
        return commonViewFactory.makePhotoViewController(title: title,
                                                         imagePath: imagePaths,
                                                         defaultImageType: .meet)
    }
}

// MARK: - Flow
extension MeetDetailSceneDIContainer {
    
    // MARK: - 일정 생성
    func makePlanCreateFlowCoordinator(meet: MeetSummary, completion: ((Plan) -> Void)?) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            commonViewFactory: commonViewFactory,
            userSession: userSession,
            type: .newInMeeting(meet))
        return planCreateDI.makePlanCreateFlowCoordinator(completionHandler: completion)
    }
    
    // MARK: - 포스트 상세
    func makePostDetailFlowCoordinator(postId: Int,
                                       type: PostType) -> BaseCoordinator {
        let planDetailDI = PostDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonViewFactory,
                                                      userSession: userSession,
                                                      type: type,
                                                      postId: postId)
        return planDetailDI.makePostDetailCoordinator()
    }
}

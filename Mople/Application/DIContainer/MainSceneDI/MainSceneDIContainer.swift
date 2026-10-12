//
//  MainSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit
import Domain
import Data

typealias MainSceneDependencies = MainTapDependencies

protocol MainTapDependencies {
    // MARK: - TabBar
    func makeMainTabBarController(coordinator: MainCoordination) -> MainTabBarController
    
    // MARK: - Tabbar Configure
    func makeHomeFlowCoordinator() -> BaseCoordinator
    func makeMeetListFlowCoordinator() -> BaseCoordinator
    func makeCalendarFlowCoordinator() -> BaseCoordinator
    func makeProfileCoordinator() -> BaseCoordinator
    
    // MARK: - NotificationDestination
    func makeNotificationDestination(type: NotificationDestination) -> BaseCoordinator
}

final class MainSceneDIContainer: BaseContainer {

    private let isLogin: Bool

    init(isLogin: Bool,
         appNetworkService: AppNetworkService,
         commonFactory: ViewDependencies,
         userSession: UserSessionProvider) {
        self.isLogin = isLogin
        super.init(appNetworkService: appNetworkService,
                   commonFactory: commonFactory,
                   userSession: userSession)
    }
    
    func makeMainFlowCoordinator(navigationController: AppNaviViewController) -> MainSceneCoordinator {
        let flow = MainSceneCoordinator(navigationController: navigationController,
                                     dependencies: self)
        return flow
    }
}

// MARK: - TabBar
extension MainSceneDIContainer: MainSceneDependencies {
    func makeMainTabBarController(coordinator: MainCoordination) -> MainTabBarController {
        return MainTabBarController(reactor: makeMainTabBarReactor(coordinator: coordinator))
    }
    
    private func makeMainTabBarReactor(coordinator: MainCoordination) -> MainTabBarReactor {
        return .init(isLogin: isLogin,
                     uploadFCMTokcnUseCase: makeUploadFCMTokenUseCase(),
                     joinMeetUseCase: makeJoinMeetUseCase(),
                     resetNotifyCountUseCase: makeResetNotifyCountUseCase(),
                     notificationService: DefaultNotificationService(),
                     coordinator: coordinator)
    }
    
    private func makeUploadFCMTokenUseCase() -> UploadFCMToken {
        let fcmTokenRepo = DefaultFCMTokenRepo(networkService: appNetworkService)
        let tokenProvider = DefaultFCMTokenProvider()
        #if DEV
        let useCase = MockDataManager.resolve(UploadFCMTokenUseCase(repo: fcmTokenRepo, tokenProvider: tokenProvider) as UploadFCMToken, mock: MockUploadFCMTokenUseCase())
        #else
        let useCase = UploadFCMTokenUseCase(repo: fcmTokenRepo, tokenProvider: tokenProvider)
        #endif
        return useCase
    }
    
    private func makeResetNotifyCountUseCase() -> ResetNotifyCount {
        let notifyRepo = DefaultNotifyRepo(networkService: appNetworkService, badgeResetter: DefaultBadgeResetter())
        #if DEV
        let useCase = MockDataManager.resolve(ResetNotifyCountUseCase(repo: notifyRepo) as ResetNotifyCount, mock: MockResetNotifyCountUseCase())
        #else
        let useCase = ResetNotifyCountUseCase(repo: notifyRepo)
        #endif
        return useCase
    }
    
    private func makeJoinMeetUseCase() -> JoinMeet {
        let meetRepo = DefaultMeetRepo(networkService: appNetworkService)
        #if DEV
        let useCase = MockDataManager.resolve(JoinMeetUseCase(repo: meetRepo) as JoinMeet, mock: MockJoinMeetUseCase())
        #else
        let useCase = JoinMeetUseCase(repo: meetRepo)
        #endif
        return useCase
    }
}

// MARK: - TabBar Item
extension MainSceneDIContainer {
    func makeHomeFlowCoordinator() -> BaseCoordinator {
        let homeSceneDI = HomeSceneDIContainer(appNetworkService: appNetworkService,
                                               commonFactory: commonViewFactory,
                                               userSession: userSession)
        return homeSceneDI.makeHomeFlowCoordinator()
    }

    // MARK: - 모임 리스트
    func makeMeetListFlowCoordinator() -> BaseCoordinator {
        let meetListSceneDI = MeetListSceneDIConatiner(appNetworkService: appNetworkService,
                                                       commonFactory: commonViewFactory,
                                                       userSession: userSession)
        return meetListSceneDI.makeMeetListFlowCoordinator()
    }

    // MARK: - 캘린더
    func makeCalendarFlowCoordinator() -> BaseCoordinator {
        let calendarSceneDI = CalendarSceneDIContainer(appNetworkService: appNetworkService,
                                                       commonFactory: commonViewFactory,
                                                       userSession: userSession)
        return calendarSceneDI.makeCalendarFlowCoordinator()
    }

    // MARK: - 프로필
    func makeProfileCoordinator() -> BaseCoordinator {
        let profileDI = ProfileSceneDIContainer(appNetworkService: appNetworkService,
                                                commonFactory: commonViewFactory,
                                                userSession: userSession)
        return profileDI.makeSetupFlowCoordinator()
    }
}

// MARK: - Handle Notification Destination
extension MainSceneDIContainer {
    func makeNotificationDestination(type: NotificationDestination) -> BaseCoordinator {
        switch type {
        case let .meet(id):
            return makeMeetDetailFlowCoordinator(meetId: id)
        case let .plan(id):
            return makePlanDetailFlowCoordinator(postId: id, type: .plan)
        case let .review(id):
            return makePlanDetailFlowCoordinator(postId: id, type: .review)
        }
    }
    
    /// 모임상세 플로우
    private func makeMeetDetailFlowCoordinator(meetId: Int) -> BaseCoordinator {
        let meetDetailDI = MeetDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonViewFactory,
                                                      userSession: userSession,
                                                      meetId: meetId,
                                                      isJoin: false)
        return meetDetailDI.makeMeetDetailCoordinator()
    }
    
    /// 일정 상세 플로우
    private func makePlanDetailFlowCoordinator(postId: Int,
                                               type: PostType) -> BaseCoordinator {
        let planDetailDI = PostDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonViewFactory,
                                                      userSession: userSession,
                                                      type: type,
                                                      postId: postId)
        return planDetailDI.makePostDetailCoordinator()
    }
}

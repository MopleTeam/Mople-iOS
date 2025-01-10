//
//  MainSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

typealias MainSceneDependencies = MainTapDependencies & MainNavigationDependencies

protocol MainTapDependencies {
    func makeHomeViewController(coordinator: HomeCoordination) -> HomeViewController
    func makeMeetListViewController(coordinator: MainCoordination) -> MeetListViewController
    func makeCalendarScheduleViewcontroller() -> CalendarScheduleViewController
    func makeProfileCoordinator() -> BaseCoordinator
}

protocol MainNavigationDependencies {
    func makeCreateMeetViewController(coordinator: CreateMeetCoordination) -> CreateMeetViewController
    func makeDetailMeetCoordinator(meetId: Int) -> BaseCoordinator
    func makePlanCreateCoordinator() -> BaseCoordinator
}

final class MainSceneDIContainer: MainSceneDependencies {
    private var FCMTokenManager: FCMTokenManager?

    private let appNetworkService: AppNetworkService
    let commonDependencies: CommonDependencies

    init(appNetworkService: AppNetworkService,
         commonDependencies: CommonDependencies,
         isFirstStart: Bool) {
        self.appNetworkService = appNetworkService
        self.commonDependencies = commonDependencies
        makeFCMTokenManager(isFirstStart: isFirstStart)
    }
    
    func makeMainFlowCoordinator(navigationController: UINavigationController) -> MainSceneCoordinator {
        let flow = MainSceneCoordinator(navigationController: navigationController,
                                     dependencies: self)
        return flow
    }
}

// MARK: - FCMToken Manager
extension MainSceneDIContainer {
    private func makeFCMTokenManager(isFirstStart: Bool)  {
        FCMTokenManager = .init(repo: makeFCMTokenRepo(),
                                isRefresh: isFirstStart)
    }
    
    private func makeFCMTokenRepo() -> FCMTokenUploadRepo {
        return DefaultFCMTokenRepo(networkService: appNetworkService)
    }
}

// MARK: - Tabbar
extension MainSceneDIContainer {
    func makeHomeViewController(coordinator: HomeCoordination) -> HomeViewController {
        let title = TextStyle.Tabbar.home
        
        let homeVC = HomeViewController(reactor: makeHomeViewReactor(coordinator: coordinator))
        homeVC.tabBarItem = .init(title: title, image: .home, selectedImage: nil)
        return homeVC
    }
    
    private func makeHomeViewReactor(coordinator: HomeCoordination) -> HomeViewReactor {
        return HomeViewReactor(fetchRecentScheduleUseCase: makeRecentPlanUseCase(),
                               notificationService: makeNotificationService(),
                               coordinator: coordinator)
    }
    
    private func makeRecentPlanUseCase() -> FetchRecentPlan {
        return FetchRecentPlanUseCase(recentPlanRepo: makeRecentPlanRepo())
    }
    
    private func makeRecentPlanRepo() -> RecentPlanListRepo {
        return DefaultRecentPlanListRepo(networkServbice: appNetworkService)
    }
    
    private func makeNotificationService() -> NotificationService {
        return DefaultNotificationService()
    }
    
    // MARK: - 모임 리스트
    func makeMeetListViewController(coordinator: MainCoordination) -> MeetListViewController {
        let titel = TextStyle.Tabbar.group
        
        let meetListVC = MeetListViewController(title: titel,
                                                  reactor: makeMeetListViewReactor(coordinator: coordinator))
        meetListVC.tabBarItem = .init(title: titel, image: .people, selectedImage: nil)
        return meetListVC
    }
    
    private func makeMeetListViewReactor(coordinator: MainCoordination) -> MeetListViewReactor {
        return MeetListViewReactor(fetchUseCase: makeMeetListUseCase(), // FetchGroupListMock()
                                    coordinator: coordinator)
    }
    
    private func makeMeetListUseCase() -> FetchMeetList {
        return FetchMeetListUseCase(meetListRepo: makeMeetListRepo())
    }
    
    private func makeMeetListRepo() -> MeetListRepo {
        return DefaultMeetListRepo(networkService: appNetworkService)
    }
    
    // MARK: - 캘린더
    func makeCalendarScheduleViewcontroller() -> CalendarScheduleViewController {
        let title = TextStyle.Tabbar.calendar
        
        let calendarScheduleVC = CalendarScheduleViewController(title: title,
                                                                reactor: makeCalendarViewReactor())
        calendarScheduleVC.tabBarItem = .init(title: title, image: .tabBarCalendar, selectedImage: nil)
        return calendarScheduleVC
    }

    private func makeCalendarViewReactor() -> CalendarViewReactor {
        return CalendarViewReactor(fetchUseCase: FetchScheduleMock())
    }

    // MARK: - 프로필
    func makeProfileCoordinator() -> BaseCoordinator {
        
        let profileDI = ProfileSceneDIContainer(appNetworkService: appNetworkService,
                                                commonDependencies: commonDependencies)
        
        let navigationController = UINavigationController.createFullScreenNavigation()
        navigationController.tabBarItem = .init(title: TextStyle.Tabbar.profile,
                                                image: .person,
                                                selectedImage: nil)
        
        return profileDI.makeSetupFlowCoordinator(navigationController: navigationController)
    }
}

// MARK: - Main Navigation
extension MainSceneDIContainer {
    // MARK: - 그룹 생성 화면
    func makeCreateMeetViewController(coordinator: CreateMeetCoordination) -> CreateMeetViewController {
        let createGroupVC = CreateMeetViewController(title: TextStyle.CreateGroup.title,
                                                      reactor: makeCreateMeetViewReactor(coordinator: coordinator))
        createGroupVC.configureModalPresentation()
        return createGroupVC
    }
    
    private func makeCreateMeetViewReactor(coordinator: CreateMeetCoordination) -> CreateMeetViewReactor {
        return .init(createMeetUseCase: makeCreateMeetUseCase(), // CreateGroupMock()
                     coordinator: coordinator)
    }
    
    private func makeCreateMeetUseCase() -> CreateMeet {
        return CreateGroupUseCase(imageUploadRepo: makeImageUploadRepo(),
                                  createMeetRepo: makeCreateMeetRepo())
    }
    
    private func makeImageUploadRepo() -> ImageUploadRepo {
        return DefaultImageUploadRepo(networkService: appNetworkService)
    }
    
    private func makeCreateMeetRepo() -> CreateMeetRepo {
        return DefaultCreateMeetRepo(networkService: appNetworkService)
    }
    
    // MARK: - 일정 생성 화면
    func makePlanCreateCoordinator() -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            fetchMeetListUseCase: FetchMeetListUseCase(meetListRepo: makeMeetListRepo()) )
        
        let navigationController = UINavigationController.createFullScreenNavigation()
        return planCreateDI.makePlanCreateFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 미팅 상세 뷰
    func makeDetailMeetCoordinator(meetId: Int) -> BaseCoordinator {
        let detailMeetDI = MeetDetailSceneDIContainer(appNetworkService: appNetworkService, meetId: meetId)
        let navigationController = UINavigationController.createFullScreenNavigation()
        return detailMeetDI.makeMeetDetailCoordinator(navigationController: navigationController)
    }
}

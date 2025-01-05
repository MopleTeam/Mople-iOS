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
    func makeCreateGroupViewController(coordinator: CreateMeetCoordination) -> CreateMeetViewController
    func makeDetailMeetCoordinator(meetId: Int) -> BaseCoordinator
    func makePlanCreateCoordinator() -> BaseCoordinator
}

final class MainSceneDIContainer: MainSceneDependencies {
    private lazy var FCMTokenManager: FCMTokenManager = {
        return .init(repo: DefaultFCMTokenRepo(networkService: appNetworkService))
    }()

    private let appNetworkService: AppNetworkService
    let commonDependencies: CommonDependencies

    init(appNetworkService: AppNetworkService,
         commonDependencies: CommonDependencies) {
        self.appNetworkService = appNetworkService
        self.commonDependencies = commonDependencies
    }
    
    func makeMainFlowCoordinator(navigationController: UINavigationController) -> MainSceneCoordinator {
        let flow = MainSceneCoordinator(navigationController: navigationController,
                                     dependencies: self)
        return flow
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
        return HomeViewReactor(fetchRecentScheduleUseCase: FetchRecentScheduleMock(),
                               refreshFCMTokenUseCase: makeRefreshFCMTokenUseCase(),
                               coordinator: coordinator)
    }
    
    private func makeRefreshFCMTokenUseCase() -> ReqseutRefreshFCMToken {
        return RefreshFCMTokenUseCase(tokenRefreshManager: FCMTokenManager)
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
        return MeetListViewReactor(fetchUseCase: FetchGroupListMock(),
                                    coordinator: coordinator)
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
    func makeCreateGroupViewController(coordinator: CreateMeetCoordination) -> CreateMeetViewController {
        let createGroupVC = CreateMeetViewController(title: TextStyle.CreateGroup.title,
                                                      reactor: makeCreateGroupViewReactor(coordinator: coordinator))
        createGroupVC.configureModalPresentation()
        return createGroupVC
    }
    
    private func makeCreateGroupViewReactor(coordinator: CreateMeetCoordination) -> CreateMeetViewReactor {
        return .init(createMeetUseCase: CreateGroupMock(),
                     coordinator: coordinator)
    }
    
    // MARK: - 일정 생성 화면
    func makePlanCreateCoordinator() -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(appNetworkService: appNetworkService)
        let navigationController = UINavigationController.createFullScreenNavigation()
        return planCreateDI.makePlanCreateFlowCoordinator(navigationController: navigationController)
    }
    
    func makeDetailMeetCoordinator(meetId: Int) -> BaseCoordinator {
        let detailMeetDI = DetailGroupSceneDIContainer(appNetworkService: appNetworkService, meetId: meetId)
        let navigationController = UINavigationController.createFullScreenNavigation()
        return detailMeetDI.makeDetailMeetCoordinator(navigationController: navigationController)
    }
}

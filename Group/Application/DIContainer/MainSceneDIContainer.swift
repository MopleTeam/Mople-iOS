//
//  MainSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

final class MainSceneDIContainer: MainSceneDependencies {
    
    let appNetworkService: AppNetWorkService
    
    init(appNetworkService: AppNetWorkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeMainFlowCoordinator(navigationController: UINavigationController) -> MainSceneCoordinator {
        let flow = MainSceneCoordinator(navigationController: navigationController,
                                     dependencies: self)
        return flow
    }
}

extension MainSceneDIContainer {
    func makeTabBarController() -> UITabBarController {
        return DefaultTabBarController()
    }
}

extension MainSceneDIContainer {
    // MARK: - 홈
    func makeHomeViewController(action: HomeViewAction) -> HomeViewController {
        let homeVC = HomeViewController(reactor: makeHomeViewReactor(action))
        homeVC.tabBarItem = .init(title: "홈", image: .home, selectedImage: nil)
        return homeVC
    }
    
    private func makeHomeViewReactor(_ action: HomeViewAction) -> HomeViewReactor {
        return HomeViewReactor(fetchRecentSchedule: FetchRecentScheduleMock(),
                                   viewAction: action)
    }
    
    // MARK: - 모임 리스트
    func makeGroupListViewController() -> GroupListViewController {
        let groupListVC = GroupListViewController(title: "모임",
                                                  reactor: makeGroupListViewReactor())
        groupListVC.tabBarItem = .init(title: "모임", image: .people, selectedImage: nil)
        return groupListVC
    }
    
    private func makeGroupListViewReactor() -> GroupListViewReactor {
        return GroupListViewReactor(fetchUseCase: FetchGroupListMock())
    }
    
    // MARK: - 캘린더
    func makeCalendarScheduleViewcontroller() -> CalendarScheduleViewController {
        let calendarScheduleVC = CalendarScheduleViewController(title: "일정관리",
                                                                reactor: makeCalendarViewReactor())
        calendarScheduleVC.tabBarItem = .init(title: "일정관리", image: .tabBarCalendar, selectedImage: nil)
        return calendarScheduleVC
    }

    private func makeCalendarViewReactor() -> CalendarViewReactor {
        return CalendarViewReactor(fetchUseCase: FetchScheduleMock())
    }

    // MARK: - 프로필
    func makeSetupSceneCoordinator() -> BaseCoordinator {
        let profileDI = ProfileSceneDIContainer(appNetworkService: appNetworkService)
        
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        navigationController.tabBarItem = .init(title: "프로필",
                                                image: .person,
                                                selectedImage: nil)
        
        return profileDI.makeSetupFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 프로필 편집
    func makeProfileEditViewController(previousProfile: ProfileInfo, action: ProfileSetupAction) -> ProfileEditViewController {
        return .init(profile: previousProfile,
                     reactor: makeProfileEditViewReactor(action))
    }
    
    private func makeProfileEditViewReactor(_ action: ProfileSetupAction) -> ProfileFormViewReactor {
        return .init(profileRepository: ProfileRepositoryMock(),
                     completedAction: action)
    }
}

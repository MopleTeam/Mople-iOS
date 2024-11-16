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
        let title = TextStyle.Tabbar.home
        
        let homeVC = HomeViewController(reactor: makeHomeViewReactor(action))
        homeVC.tabBarItem = .init(title: title, image: .home, selectedImage: nil)
        return homeVC
    }
    
    private func makeHomeViewReactor(_ action: HomeViewAction) -> HomeViewReactor {
        return HomeViewReactor(fetchRecentSchedule: FetchRecentScheduleMock(),
                                   viewAction: action)
    }
    
    // MARK: - 모임 리스트
    func makeGroupListViewController() -> GroupListViewController {
        let titel = TextStyle.Tabbar.group
        
        let groupListVC = GroupListViewController(title: titel,
                                                  reactor: makeGroupListViewReactor())
        groupListVC.tabBarItem = .init(title: titel, image: .people, selectedImage: nil)
        return groupListVC
    }
    
    private func makeGroupListViewReactor() -> GroupListViewReactor {
        return GroupListViewReactor(fetchUseCase: FetchGroupListMock())
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
    func makeProfileSceneCoordinator() -> BaseCoordinator {
        
        let profileDI = ProfileSceneDIContainer(appNetworkService: appNetworkService)
        
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        navigationController.tabBarItem = .init(title: TextStyle.Tabbar.profile,
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
    
    
    // MARK: - 그룹 생성 화면
    func makeCreateGroupViewController() -> GroupCreateViewController {
        let title = TextStyle.CreateGroup.title
        return .init(title: title)
    }
}

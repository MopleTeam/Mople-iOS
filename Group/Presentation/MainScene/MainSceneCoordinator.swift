//
//  TapBarCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol MainSceneDependencies {
    func makeTabBarController() -> UITabBarController
    func makeHomeViewController(action: HomeViewAction) -> HomeViewController
    func makeGroupListViewController() -> GroupListViewController
    func makeCalendarScheduleViewcontroller() -> CalendarScheduleViewController
    func makeSetupSceneCoordinator() -> BaseCoordinator
    func makeProfileEditViewController(previousProfile: ProfileInfo,
                                       action: ProfileSetupAction) -> ProfileEditViewController
}

protocol AccountAction {
    func signOut()
    func editProfile(_ editModel: ProfileUpdateModel)
}

private enum Route {
    case home, group, calendar, profile
    
    var type: UIViewController.Type {
        switch self {
        case .home:
            return HomeViewController.self
        case .group:
            return GroupListViewController.self
        case .calendar:
            return CalendarScheduleViewController.self
        case .profile:
            return ProfileViewController.self
        }
    }
}

final class MainSceneCoordinator: BaseCoordinator {
    
    private let dependencies: MainSceneDependencies
    private var tabBarController: UITabBarController?
 
    init(navigationController: UINavigationController,
         dependencies: MainSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        tabBarController = dependencies.makeTabBarController()
        tabBarController!.setViewControllers(getTabs(), animated: false)
        navigationController.pushViewController(tabBarController!, animated: true)
    }
}

// MARK: - Main Views 생성
extension MainSceneCoordinator {
    private func getTabs() -> [UIViewController] {
        return [getHomeViewController(),
                getGroupListViewController(),
                getCalendarScheduleViewController(),
                getSetupViewController()]
    }
    
    private func getHomeViewController() -> HomeViewController {
        let action = HomeViewAction(logOut: signOut,
                                    presentNextEvent: pushCalendarView(lastRecentDate:))
        return dependencies.makeHomeViewController(action: action)
    }
    
    private func getGroupListViewController() -> GroupListViewController {
        return dependencies.makeGroupListViewController()
    }
    
    private func getCalendarScheduleViewController() -> CalendarScheduleViewController {
        return dependencies.makeCalendarScheduleViewcontroller()
    }
    
    private func getSetupViewController() -> UINavigationController {
        let childCoordinator = dependencies.makeSetupSceneCoordinator()
        self.start(coordinator: childCoordinator)
        return childCoordinator.navigationController
    }
}

// MARK: - 로그아웃 -> 로그인 뷰로 돌아가기
extension MainSceneCoordinator: AccountAction {
    
    func editProfile(_ editModel: ProfileUpdateModel) {
        let action: ProfileSetupAction = .init(completed: editModel.completedAction)
        
        let profileEditView = dependencies.makeProfileEditViewController(previousProfile: editModel.currentProfile,
                                                                         action: action)
        self.navigationController.pushViewController(profileEditView, animated: true)
    }
    
    /// 로그아웃 및 회원탈퇴 후 로그인 화면으로 넘어가기
    func signOut() {
        fadeOut { [weak self] in
            self?.clearScene()
        }
    }
}

extension MainSceneCoordinator {
    /// 캘린더 뷰로 이동하기
    /// - Parameter lastRecentDate: 이동시 표시할 데이트
    func pushCalendarView(lastRecentDate: Date) {
        guard let index = getIndexFromTabBar(destination: .calendar),
              let destinationNavi = getDestinationVC(index: index),
              let calendarVC = destinationNavi as? CalendarScheduleViewController else { return }
        calendarVC.presentEvent(on: lastRecentDate)
        tabBarController!.selectedIndex = index
    }
}

// MARK: - Helper
extension MainSceneCoordinator {
    
    /// 로그아웃, 회원탈퇴 시 자식 뷰 지우기
    private func clearScene() {
        self.childCoordinators.forEach {
            $0.navigationController.viewControllers = []
            self.didFinish(coordinator: $0)
        }
        
        self.childCoordinators.removeAll()
        self.tabBarController!.viewControllers?.removeAll()
        
        self.navigationController.viewControllers = []
        self.parentCoordinator?.didFinish(coordinator: self)
        (self.parentCoordinator as? SignOutListener)?.signOut()
    }
    
    #warning("메타타입 비교하기, Claude 타입과 메타타입 참고")
    /// 이동하려고 하는 뷰의 Navi Index 찾기
    private func getIndexFromTabBar(destination: Route) -> Int? {
        return tabBarController?.viewControllers?.firstIndex(where: { vc in
            return vc.isKind(of: destination.type)
        })
    }
    
    /// 이동하려고 하는 뷰 찾기
    private func getDestinationVC(index: Int) -> UIViewController? {
        return tabBarController?.viewControllers?[index]
    }
}



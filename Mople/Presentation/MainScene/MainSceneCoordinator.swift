//
//  TapBarCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol MainCoordination: AnyObject {
    func showCalendar(startingFrom date: Date)
    func signOut()
}



final class MainSceneCoordinator: BaseCoordinator {
    
    private(set) var dependencies: MainSceneDependencies
    private(set) var tabBarController = DefaultTabBarController()
 
    init(navigationController: AppNaviViewController,
         dependencies: MainSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        tabBarController.setViewControllers(getTabs(), animated: false)
        navigationController.pushViewController(tabBarController, animated: false)
    }
    
    private func getTabs() -> [UIViewController] {
        return [getHomeFlowNavigation(),
                getMeetListFlowNavigation(),
                getCalendarFlowNavigation(),
                getProfileFlowNavigation()]
    }
}

// MARK: - Tabbar
extension MainSceneCoordinator {
    private func getHomeFlowNavigation() -> UINavigationController {
        let homeFlowCoordinator = dependencies.makeHomeFlowCoordinator()
        self.start(coordinator: homeFlowCoordinator)
        return homeFlowCoordinator.navigationController
    }
    
    private func getMeetListFlowNavigation() -> UINavigationController {
        let meetListFlowCoordinator = dependencies.makeMeetListFlowCoordinator()
        self.start(coordinator: meetListFlowCoordinator)
        return meetListFlowCoordinator.navigationController
    }
    
    private func getCalendarFlowNavigation() -> UINavigationController {
        let calendarFlowCoordinator = dependencies.makeCalendarFlowCoordinator()
        self.start(coordinator: calendarFlowCoordinator)
        return calendarFlowCoordinator.navigationController
    }
    
    private func getProfileFlowNavigation() -> UINavigationController {
        let profileFlowCoordinator = dependencies.makeProfileCoordinator()
        self.start(coordinator: profileFlowCoordinator)
        return profileFlowCoordinator.navigationController
    }
}

extension MainSceneCoordinator: MainCoordination {
    
    // MARK: - 로그아웃
    /// 로그아웃 및 회원탈퇴 후 로그인 화면으로 넘어가기
    func signOut() {
        fadeOut { [weak self] in
            self?.clearScene()
        }
    }
    
    /// 로그아웃, 회원탈퇴 시 자식 뷰 지우기
    private func clearScene() {
        self.clearUp()
        self.tabBarController.viewControllers?.removeAll()
        self.parentCoordinator?.didFinish(coordinator: self)
        (self.parentCoordinator as? SignOutListener)?.signOut()
    }
    
    // MARK: - 루트뷰로 돌아오기
    func returnToRootView() {
        self.navigationController.dismiss(animated: true)
    }
}

// MARK: - 탭바 컨트롤
extension MainSceneCoordinator {
    enum Route: Int {
        case home, meetList, calendar, profile
    }
    
    /// 캘린더 탭으로 전환하기
    /// - Parameter date: 캘린더 탭에서 보여줄 날짜
    func showCalendar(startingFrom date: Date) {
        tabBarController.selectedIndex = Route.calendar.rawValue
        guard let calendarVC = tabBarController.viewcController(ofType: CalendarScheduleViewController.self) else { return }
        calendarVC.presentEvent(on: date)
    }
}

// MARK: - Handle Notification Tap
extension MainSceneCoordinator {
    func handleNitification(destination: NotificationDestination) {
        let destination = dependencies.makeNotificationDestination(type: destination)
        self.start(coordinator: destination)
        self.navigationController.presentWithTransition(destination.navigationController)
    }
}

//
//  TapBarCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol SignOut {
    func singOut()
}

protocol PresentCalendar {
    func presentCalendar()
}

protocol TabBarCoordinaotorDependencies {
    func makeTabBarController() -> UITabBarController
    func getMainFlowCoordinator() -> [BaseCoordinator]
}

final class TabBarCoordinator: BaseCoordinator {
    
    private let dependencies: TabBarCoordinaotorDependencies
    private var tabBarController: UITabBarController?
 
    init(navigationController: UINavigationController,
         dependencies: TabBarCoordinaotorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        tabBarController = dependencies.makeTabBarController()
        let coordinators = dependencies.getMainFlowCoordinator()
        coordinators.forEach {
            $0.navigationController.navigationBar.isHidden = true
            self.start(coordinator: $0)
        }
        let viewControllers = coordinators.map { $0.navigationController }
        tabBarController!.setViewControllers(viewControllers, animated: false)
        navigationController.pushViewController(tabBarController!, animated: true)
    }
}

// MARK: - 로그아웃 -> 로그인 뷰로 돌아가기
extension TabBarCoordinator: SignOut {
    
    func singOut() {
        fadeOut { [weak self] in
            self?.clearScene()
        }
    }
    
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
}

extension TabBarCoordinator: PresentCalendar {
    func presentCalendar() {
        // 탭바 컨트롤러s에는 Navigation View Controller가 들어있음
        
        guard let calendarIndex = getCalendarIndex(),
              let calendarVC = getCalendarFormTabBar(index: calendarIndex) else { return }
        
        tabBarController!.selectedIndex = calendarIndex
    }
    
    private func getCalendarIndex() -> Int? {
        return tabBarController?.viewControllers?.firstIndex(where: { navi in
            guard let navi = navi as? UINavigationController else { return false }
            return navi.viewControllers.contains { vc in
                return vc is CalendarScheduleViewController
            }
        })
    }
    
    private func getCalendarFormTabBar(index: Int) -> CalendarScheduleViewController? {
        guard let calendarNavi = tabBarController?.viewControllers?[index] as? UINavigationController,
              let calendarVC = calendarNavi.viewControllers.first as? CalendarScheduleViewController else { return nil }
        
        return calendarVC
    }
}

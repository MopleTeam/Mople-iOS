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

protocol KeepTabBarNavigation {
    func pushCalendarView(lastRecentDate: Date?)
}

protocol HideTabBarNavigation {
    
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



// MARK: - 탭바 유지한 상태로 Push
extension TabBarCoordinator: KeepTabBarNavigation {
    
    /// 캘린더 뷰로 이동하기
    /// - Parameter lastRecentDate: 이동시 표시할 데이트
    func pushCalendarView(lastRecentDate: Date? = nil) {
        guard let index = getNaviIndexFromTabBar(destination: .calendar),
              let destinationNavi = getDestinationFormNavi(index: index),
              let calendarVC = destinationNavi as? CalendarScheduleViewController else { return }
        
        calendarVC.presentEvent(on: lastRecentDate)
        tabBarController!.selectedIndex = index
    }
}

// MARK: - 탭바를 사용하지 않는 상태로 Push
extension TabBarCoordinator: HideTabBarNavigation {
    func pushEditProfileView() {
        
    }
}

// MARK: - Helper
extension TabBarCoordinator {
    
    #warning("메타타입 비교하기, Claude 타입과 메타타입 참고")
    /// 이동하려고 하는 뷰의 Navi Index 찾기
    private func getNaviIndexFromTabBar(destination: Route) -> Int? {
        return tabBarController?.viewControllers?.firstIndex(where: { navi in
            guard let navi = navi as? UINavigationController else { return false }
            return navi.viewControllers.contains { vc in
                return vc.isKind(of: destination.type)
            }
        })
    }
    
    /// 이동하려고 하는 뷰 찾기
    private func getDestinationFormNavi(index: Int) -> UIViewController? {
        guard let destinationNavi = tabBarController?.viewControllers?[index] as? UINavigationController else { return nil }
        return destinationNavi.viewControllers.first
    }
}


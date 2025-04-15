//
//  TapBarCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol MainCoordination: AnyObject {
    func changeCalendarTap(date: Date)
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
    
    func changeCalendarTap(date: Date) {
        switchTap(route: .calendar(presentDate: date))
    }
    
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
    enum Route {
        case home, group, profile
        case calendar(presentDate: Date)
        
        var type: UIViewController.Type {
            switch self {
            case .home:
                return HomeViewController.self
            case .group:
                return MeetListViewController.self
            case .calendar:
                return CalendarScheduleViewController.self
            case .profile:
                return ProfileViewController.self
            }
        }
    }

    /// 새로운 일정 및 그룹 생성 후 그룹 리스트 탭으로 이동
    public func switchTap(route: Route) {
        
        let destination = getIndexFromTabBar(destination: route)
        guard let index = destination.index,
              let vc = destination.destinationVC,
              self.tabBarController.selectedIndex != index else { return }
        
        tabBarController.selectedIndex = index
        
        switch route {
        case let .calendar(presentDate):
            guard let calendarVC = vc as? CalendarScheduleViewController else { return }
            calendarVC.presentEvent(on: presentDate)
        default:
            break
        }
    }
    
    /// 변경하고자 하는 VC가 해당하는 탭 Index 찾기
    private func getIndexFromTabBar(destination: Route) -> (index: Int?, destinationVC: UIViewController?) {
        var destinationVC: UIViewController?
        
        let index = tabBarController.viewControllers?.firstIndex(where: { vc in
            guard let navi = vc as? UINavigationController else { return false }
            return navi.viewControllers.contains {
                if $0.isKind(of: destination.type) {
                    destinationVC = $0
                    return true
                } else { return false }
            }
        })
        
        return (index, destinationVC)
    }
}

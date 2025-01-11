//
//  TapBarCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol MainCoordination: AnyObject {
    func closeSubView(completion: (() -> Void)?)
    func presentCreateGroupView()
    func presentCreatePlanScene()
    func presentDetailMeetScene(meetId: Int)
    func signOut()
}

final class MainSceneCoordinator: BaseCoordinator {
    
    private(set) var dependencies: MainSceneDependencies
    private(set) var tabBarController = DefaultTabBarController()
 
    init(navigationController: UINavigationController,
         dependencies: MainSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        tabBarController.setViewControllers(getTabs(), animated: false)
        navigationController.pushViewController(tabBarController, animated: true)
    }
    
    private func getTabs() -> [UIViewController] {
        return [getHomeViewController(),
                getGroupListViewController(),
                getCalendarScheduleViewController(),
                getProfileViewController()]
    }
}

extension MainSceneCoordinator: MainCoordination {
    func closeSubView(completion: (() -> Void)?) {
        self.navigationController.dismiss(animated: false, completion: {
            completion?()
        })
    }
    
    // MARK: - 그룹 생성 화면 이동
    /// - Parameter completedAction: 완료 후 액션 (예시: 그룹 생성 후 그룹 리스트 reload)
    func presentCreateGroupView() {
        let createGroupView = dependencies.makeCreateMeetViewController(coordinator: self)
        self.navigationController.present(createGroupView, animated: false)
    }
    
    // MARK: - 일정 생성 화면 이동
    func presentCreatePlanScene() {
        let planCreateCoordinator = self.dependencies.makePlanCreateCoordinator()
        self.start(coordinator: planCreateCoordinator)
        self.navigationController.present(planCreateCoordinator.navigationController, animated: false)
    }
    
    func presentDetailMeetScene(meetId: Int) {
        let detailGroupCoordinator = self.dependencies.makeDetailMeetCoordinator(meetId: meetId)
        self.start(coordinator: detailGroupCoordinator)
        self.navigationController.present(detailGroupCoordinator.navigationController, animated: false)
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
}

// MARK: - Tabbar
extension MainSceneCoordinator {
    private func getHomeViewController() -> HomeViewController {
        return dependencies.makeHomeViewController(coordinator: self)
    }
    
    private func getGroupListViewController() -> MeetListViewController {
        return dependencies.makeMeetListViewController(coordinator: self)
    }
    
    private func getCalendarScheduleViewController() -> CalendarScheduleViewController {
        return dependencies.makeCalendarScheduleViewcontroller()
    }
    
    private func getProfileViewController() -> UINavigationController {
        let childCoordinator = dependencies.makeProfileCoordinator()
        self.start(coordinator: childCoordinator)
        return childCoordinator.navigationController
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
        guard let groupListInex = getIndexFromTabBar(destination: route),
              self.tabBarController.selectedIndex != groupListInex else { return }
        
        tabBarController.selectedIndex = groupListInex
    }
    
    /// 변경하고자 하는 VC가 해당하는 탭 Index 찾기
    private func getIndexFromTabBar(destination: Route) -> Int? {
        return tabBarController.viewControllers?.firstIndex(where: { vc in
            if let navigationController = vc as? UINavigationController {
                return containsViewController(navigation: navigationController,
                                              destination: destination.type)
            } else {
                return prepareViewController(viewController: vc,
                            destination: destination)
            }
        })
    }
    
    private func containsViewController(navigation: UINavigationController,
                                        destination: UIViewController.Type) -> Bool {
        return navigation.viewControllers.contains(where: { view in
            view.isKind(of: destination) })
    }
    
    private func prepareViewController(viewController: UIViewController,
                      destination: Route) -> Bool {
        
        if case .calendar(let presentDate) = destination,
           let calendarVC = viewController as? CalendarScheduleViewController {
            calendarVC.presentEvent(on: presentDate)
        }
        
        return viewController.isKind(of: destination.type)
    }
}






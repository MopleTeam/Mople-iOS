//
//  TapBarCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol MainSceneDependencies {
    func makeHomeViewController(action: HomeViewAction) -> HomeViewController
    func makeGroupListViewController() -> GroupListViewController
    func makeCalendarScheduleViewcontroller() -> CalendarScheduleViewController
    func makeProfileSceneCoordinator() -> BaseCoordinator
    func makeProfileEditViewController(previousProfile: ProfileInfo,
                                       action: ProfileEditAction) -> ProfileEditViewController
    func makeCreateGroupViewController(flowAction: CreatedGroupFlowAction) -> GroupCreateViewController
    
    func makePlanCreateDIContainer() -> PlanCreateSceneContainer
}

protocol AccountAction {
    func signOut()
    func moveToProfileEditView(_ previousProfile: ProfileInfo,_ completedAction: (() -> Void)?)
}

protocol CreatedGroupFlowAction: AnyObject {
    func endProcess()
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
    private var tabBarController: UITabBarController = DefaultTabBarController()
 
    init(navigationController: UINavigationController,
         dependencies: MainSceneDependencies) {
        print(#function, #line, "LifeCycle Test MainSceneCoordinator Created" )
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test MainSceneCoordinator Deinit" )
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

// MARK: - HomeView
extension MainSceneCoordinator {
    
    private func getHomeViewController() -> HomeViewController {
        let action = HomeViewAction(presentCreateGroupView: pushCreateGroupView,
                                    presentCreatePlanView: pushCreatePlanView,
                                    presentCalendarView: pushCalendarView(lastRecentDate:))
        return dependencies.makeHomeViewController(action: action)
    }
    
    // MARK: - 캘린더 뷰 이동
    /// - Parameter lastRecentDate: 이동시 표시할 데이트
    private func pushCalendarView(lastRecentDate: Date) {
        guard let index = getIndexFromTabBar(destination: .calendar),
              let destinationNavi = getDestinationVC(index: index),
              let calendarVC = destinationNavi as? CalendarScheduleViewController else { return }
        calendarVC.presentEvent(on: lastRecentDate)
        tabBarController.selectedIndex = index
    }
    
    // MARK: - 그룹 생성 화면 이동
    /// - Parameter completedAction: 완료 후 액션 (예시: 그룹 생성 후 그룹 리스트 reload)
    private func pushCreateGroupView() {
        let createGroupView = dependencies.makeCreateGroupViewController(flowAction: self)
        self.navigationController.present(createGroupView, animated: false)
    }
    
    // MARK: - 일정 생성 화면 이동
    private func pushCreatePlanView() {
        let planCreateDI = dependencies.makePlanCreateDIContainer()
        let navigationController = UINavigationController.createFullScreenNavigation()
        let flow = planCreateDI.makePlanCreateFlowCoordinator(navigationController: navigationController)
        self.start(coordinator: flow)
        self.navigationController.present(navigationController, animated: false)
    }
    
    // MARK: - Helper
    /// 새로운 일정 및 그룹 생성 후 그룹 리스트 탭으로 이동
    private func switchToGroupListTap() {
        guard let groupListInex = getIndexFromTabBar(destination: .group),
              self.tabBarController.selectedIndex != groupListInex else { return }
        
        tabBarController.selectedIndex = groupListInex
    }
}

// MARK: - Group List
extension MainSceneCoordinator {
    private func getGroupListViewController() -> GroupListViewController {
        return dependencies.makeGroupListViewController()
    }
}

// MARK: - Calendar
extension MainSceneCoordinator {
    private func getCalendarScheduleViewController() -> CalendarScheduleViewController {
        return dependencies.makeCalendarScheduleViewcontroller()
    }
}

// MARK: - Profile
extension MainSceneCoordinator {
    private func getProfileViewController() -> UINavigationController {
        let childCoordinator = dependencies.makeProfileSceneCoordinator()
        self.start(coordinator: childCoordinator)
        return childCoordinator.navigationController
    }
}

// MARK: - 프로필 편집화면 진입
extension MainSceneCoordinator {
    func moveToProfileEditView(_ previousProfile: ProfileInfo,_ completedAction: (() -> Void)?) {
        let action: ProfileEditAction = .init {
            completedAction?()
            self.navigationController.popViewController(animated: true)
        }
        
        let profileEditView = dependencies.makeProfileEditViewController(previousProfile: previousProfile,
                                                                         action: action)
        self.navigationController.pushViewController(profileEditView, animated: true)
    }
}

// MARK: - 로그아웃 -> 로그인 뷰로 돌아가기
extension MainSceneCoordinator: AccountAction {
    /// 로그아웃 및 회원탈퇴 후 로그인 화면으로 넘어가기
    func signOut() {
        fadeOut { [weak self] in
            self?.clearScene()
        }
    }
}

extension MainSceneCoordinator: CreatedGroupFlowAction {
    func endProcess() {
        self.switchToGroupListTap()
        self.navigationController.dismiss(animated: false, completion: { [weak self] in
            self?.switchToGroupListTap()
        })
    }
}

// MARK: - Helper
extension MainSceneCoordinator {
    
    /// 로그아웃, 회원탈퇴 시 자식 뷰 지우기
    private func clearScene() {
        self.clearUp()
        self.tabBarController.viewControllers?.removeAll()
        self.parentCoordinator?.didFinish(coordinator: self)
        (self.parentCoordinator as? SignOutListener)?.signOut()
    }
    
    #warning("메타타입 비교하기, Claude 타입과 메타타입 참고")
    /// 이동하려고 하는 뷰의 Navi Index 찾기
    private func getIndexFromTabBar(destination: Route) -> Int? {
        return tabBarController.viewControllers?.firstIndex(where: { vc in
            return vc.isKind(of: destination.type)
        })
    }
    
    /// 이동하려고 하는 뷰 찾기
    private func getDestinationVC(index: Int) -> UIViewController? {
        return tabBarController.viewControllers?[index]
    }
}

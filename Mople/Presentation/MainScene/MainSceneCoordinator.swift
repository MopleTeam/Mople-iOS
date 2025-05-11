//
//  TapBarCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import RxSwift

protocol MainCoordination: AnyObject {
    func showCalendar(startingFrom date: Date)
    func showJoinedMeet(with meet: Meet)
    func startLoginFlow()
}

final class MainSceneCoordinator: BaseCoordinator {
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let mainReadySubject = ReplaySubject<Void>.create(bufferSize: 1)
    
    private let dependencies: MainSceneDependencies
    private var tabBarController: MainTabBarController?
    
    init(navigationController: AppNaviViewController,
         dependencies: MainSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        tabBarController = dependencies.makeMainTabBarController(coordinator: self)
        tabBarController?.setViewControllers(getTabs(), animated: false)
        self.push(tabBarController!, animated: false)
        mainReadySubject.onNext(())
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

// MARK: - Navigation
extension MainSceneCoordinator: MainCoordination {
        
    /// 로그아웃, 회원탈퇴 시 자식 뷰 지우기
    func startLoginFlow() {
        fadeOut { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.tabBarController?.viewControllers?.removeAll()
            self.parentCoordinator?.didFinish(coordinator: self)
            (self.parentCoordinator as? SignOutListener)?.signOut()
        }
    }
}

// MARK: - Handle TabBar
extension MainSceneCoordinator {
    enum Route: Int {
        case home, meetList, calendar, profile
    }
    
    /// 캘린더 탭으로 전환하기
    /// - Parameter date: 캘린더 탭에서 보여줄 날짜
    func showCalendar(startingFrom date: Date) {
        guard let calendarVC = tabBarController?.viewController(ofType: CalendarPostViewController.self) else {
            return
        }
        tabBarController?.selectedIndex = Route.calendar.rawValue
        calendarVC.presentEvent(on: date)
    }
    
    func showJoinedMeet(with meet: Meet) {
        guard let meetListVC = tabBarController?.viewController(ofType: MeetListViewController.self) else {
            return
        }
        tabBarController?.selectedIndex = Route.meetList.rawValue
        meetListVC.presentJoinMeet(with: meet)
    }
}

// MARK: - Handle Notification Tap
extension MainSceneCoordinator {
    func handleNotification(destination: NotificationDestination) {
        tabBarController?.resetNotify()
        let destination = dependencies.makeNotificationDestination(type: destination)
        self.start(coordinator: destination)
        self.present(destination.navigationController)
    }
}

// MARK: - Handle Invite
extension MainSceneCoordinator {
    func handleInviteMeet(code: String) {
        mainReadySubject
            .subscribe(with: self, onNext: { vc, _ in
                vc.tabBarController?.joinMeet(code: code)
            })
            .disposed(by: disposeBag)
    }
}

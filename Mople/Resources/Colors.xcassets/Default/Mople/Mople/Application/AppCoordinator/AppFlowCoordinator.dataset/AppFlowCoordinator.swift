//
//  AppCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit
import RxSwift
import RxRelay

final class AppFlowCoordinator: BaseCoordinator {
    
    // MARK: - Observable
    private var mainReadySubject = ReplaySubject<Void>.create(bufferSize: 1)
    private let appDIContainer: AppDIContainer
    private var disposeBag = DisposeBag()
 
    init(navigationController: AppNaviViewController,
         appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let launchView = appDIContainer.makeLaunchViewController(coordinator: self)
        self.pushWithTracking(launchView, animated: false)
    }
}

// MARK: - 런치 스크린
protocol LaunchCoordination: AnyObject {
    func mainFlowStart(isLogin: Bool)
    func loginFlowStart()
}

extension AppFlowCoordinator: LaunchCoordination {
    func mainFlowStart(isLogin: Bool = false) {
        self.navigationController.viewControllers.removeAll()
        let mainSceneDIContainer = appDIContainer.makeMainSceneDIContainer(isLoign: isLogin)
        let flow = mainSceneDIContainer.makeMainFlowCoordinator(navigationController: navigationController)
        start(coordinator: flow)
        setBadgeCount()
        mainReadySubject.onNext(())
    }
    
    func loginFlowStart() {
        self.navigationController.viewControllers.removeAll()
        let loginSceneDIContainer = appDIContainer.makeLoginSceneDIContainer()
        let flow = loginSceneDIContainer.makeAuthFlowCoordinator(navigationController: navigationController)
        start(coordinator: flow)
        resetBadgeCount()
    }
}

// MARK: - 로그인
protocol SignInListener {
    func signIn()
}

extension AppFlowCoordinator: SignInListener {
    func signIn() {
        mainFlowStart(isLogin: true)
    }
}

// MARK: - 로그아웃, 회원탈퇴
protocol SignOutListener {
    func signOut()
}

extension AppFlowCoordinator: SignOutListener {
    func signOut() {
        resetMainReadySubject()
        loginFlowStart()
    }
    
    private func resetMainReadySubject() {
        mainReadySubject = ReplaySubject<Void>.create(bufferSize: 1)
    }
}

// MARK: - BadgeCount
extension AppFlowCoordinator {
    private func resetBadgeCount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func setBadgeCount() {
        guard let userInfo = UserInfoStorage.shared.userInfo else { return }
        UIApplication.shared.applicationIconBadgeNumber = userInfo.notifyCount
    }
}

// MARK: - Notify Handle
extension AppFlowCoordinator { 
    func handleNotificationTap(destination: NotificationDestination) {
        mainReadySubject
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [weak self] in
                self?.routeNotification(to: destination)
            })
            .disposed(by: disposeBag)
    }
    
    private func routeNotification(to destination: NotificationDestination) {
        resetMainFlow(completion: { mainFlow in
            mainFlow.handleNotification(destination: destination)
        })
    }
}

// MARK: - Invite Handle
extension AppFlowCoordinator {
    func handleInvite(with url: URL) {
        guard let scheme = url.scheme,
              scheme == "mople",
              let inviteCode = url.queryParameters["code"] else { return }
        
        mainReadySubject
            .take(1)
            .subscribe(onNext: { [weak self] in
                self?.routeJoinMeet(with: inviteCode)
            })
            .disposed(by: disposeBag)
    }
    
    private func routeJoinMeet(with code: String) {
        resetMainFlow(completion: { mainFlow in
            mainFlow.handleInviteMeet(code: code)
        })
    }
}

extension AppFlowCoordinator {
    private func resetMainFlow(completion: ((MainSceneCoordinator) -> Void)? = nil) {
        guard let mainFlow = findChildCoordinator(ofType: MainSceneCoordinator.self) else { return }
        
        let group = DispatchGroup()
        
        mainFlow.childCoordinators.forEach {
            group.enter()
            $0.resetChildCoordinators(completion: {
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            completion?(mainFlow)
        }
    }
}


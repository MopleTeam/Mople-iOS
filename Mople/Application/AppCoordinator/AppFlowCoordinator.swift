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
    private let mainReadySubject = ReplaySubject<Void>.create(bufferSize: 1)
    
    private let appDIContainer: AppDIContainer
    private var disposeBag = DisposeBag()
 
    init(navigationController: AppNaviViewController,
         appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        super.init(navigationController: navigationController)
        bindSessionExpiration()
    }
    
    override func start() {
        let launchView = appDIContainer.makeLaunchViewController(coordinator: self)
        self.navigationController.pushViewController(launchView, animated: false)
    }
}

// MARK: - 런치 스크린
protocol LaunchCoordination: AnyObject {
    func mainFlowStart(fcmTokenRefresh: Bool)
    func loginFlowStart()
}

extension AppFlowCoordinator: LaunchCoordination {
    func mainFlowStart(fcmTokenRefresh: Bool = false) {
        self.navigationController.viewControllers.removeAll()
        let mainSceneDIContainer = appDIContainer.makeMainSceneDIContainer(isFirstStart: fcmTokenRefresh)
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
        mainFlowStart(fcmTokenRefresh: true)
    }
}

// MARK: - 로그아웃, 회원탈퇴
protocol SignOutListener {
    func signOut()
}

extension AppFlowCoordinator: SignOutListener {
    func signOut() {
        JWTTokenStorage.shared.deleteToken()
        UserInfoStorage.shared.deleteEnitity()
        UserDefaults.deleteFCMToken()
        loginFlowStart()
    }
}

// MARK: - 로그인 세션 만료
extension AppFlowCoordinator {
    private func bindSessionExpiration() {
        EventService.shared.addObservable(name: .sessionExpired)
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.signOut()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - BadgeCount
extension AppFlowCoordinator {
    private func resetBadgeCount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func setBadgeCount() {
        guard let userInfo = UserInfoStorage.shared.userInfo else { return }
        print(#function, #line, "뱃지 카운트 : \(userInfo.notifyCount)" )
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
        guard let mainFlow = findChildCoordinator(ofType: MainSceneCoordinator.self) else { return }
        mainFlow.childCoordinators.forEach { $0.resetChildCoordinators() }
        mainFlow.handleNitification(destination: destination)
    }
}

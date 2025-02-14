//
//  AppCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit

final class AppFlowCoordinator: BaseCoordinator {
    
    private let appDIContainer: AppDIContainer
 
    init(navigationController: AppNaviViewController,
         appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let launchView = appDIContainer.makeLaunchViewController(coordinator: self)
        self.navigationController.pushViewController(launchView, animated: false)
    }
}

// MARK: - 런치 스크린
protocol LaunchCoordination: AnyObject {
    func mainFlowStart(isFirstStart: Bool)
    func loginFlowStart()
}

extension AppFlowCoordinator: LaunchCoordination {
    func mainFlowStart(isFirstStart: Bool = false) {
        self.navigationController.viewControllers.removeAll()
        let mainSceneDIContainer = appDIContainer.makeMainSceneDIContainer(isFirstStart: isFirstStart)
        let flow = mainSceneDIContainer.makeMainFlowCoordinator(navigationController: navigationController)
        start(coordinator: flow)
    }
    
    func loginFlowStart() {
        print(#function, #line)
        self.navigationController.viewControllers.removeAll()
        let loginSceneDIContainer = appDIContainer.makeLoginSceneDIContainer()
        let flow = loginSceneDIContainer.makeAuthFlowCoordinator(navigationController: navigationController)
        start(coordinator: flow)
    }
}

// MARK: - 로그인
protocol SignInListener {
    func signIn()
}

extension AppFlowCoordinator: SignInListener {
    func signIn() {
        mainFlowStart(isFirstStart: true)
    }
}

// MARK: - 로그아웃, 회원탈퇴
protocol SignOutListener {
    func signOut()
}

extension AppFlowCoordinator: SignOutListener {
    func signOut() {
        loginFlowStart()
    }
}
    
    


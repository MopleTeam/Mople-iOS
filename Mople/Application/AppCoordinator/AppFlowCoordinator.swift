//
//  AppCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit

protocol SignInListener {
    func signIn()
}

protocol SignOutListener {
    func signOut()
}

final class AppFlowCoordinator: BaseCoordinator {
    
    private let appDIContainer: AppDIContainer
 
    init(navigationController: AppNaviViewController,
         appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        super.init(navigationController: navigationController)
    }
    
    
    override func start() {
        fadeOut { [weak self] in
            self?.checkEntry()
        }
    }
    
    private func checkEntry() {
        if KeyChainService.shared.hasToken() {
            self.mainFlowStart()
        } else {
            self.loginFlowStart()
        }
    }
    
    private func mainFlowStart(isFirstStart: Bool = false) {
        let mainSceneDIContainer = appDIContainer.makeMainSceneDIContainer(isFirstStart: isFirstStart)
        let flow = mainSceneDIContainer.makeMainFlowCoordinator(navigationController: navigationController)
        start(coordinator: flow)
    }
    
    private func loginFlowStart() {
        let loginSceneDIContainer = appDIContainer.makeLoginSceneDIContainer()
        let flow = loginSceneDIContainer.makeAuthFlowCoordinator(navigationController: navigationController)
        start(coordinator: flow)
    }
}

extension AppFlowCoordinator: SignInListener {
    func signIn() {
        mainFlowStart(isFirstStart: true)
    }
}

extension AppFlowCoordinator: SignOutListener {
    func signOut() {
        loginFlowStart()
    }
}
    
    


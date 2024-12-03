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
 
    init(navigationController: UINavigationController,
         appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        super.init(navigationController: navigationController)
    }
    
    
    override func start() {
        self.navigationController.navigationBar.isHidden = true
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
    
    private func mainFlowStart() {
        let mainSceneDIContainer = appDIContainer.makeMainSceneDIContainer()
        let flow = mainSceneDIContainer.makeMainFlowCoordinator(navigationController: navigationController)
        start(coordinator: flow)
    }
    
    private func loginFlowStart() {
        let loginSceneDIContainer = appDIContainer.makeLoginSceneDIContainer()
        let flow = loginSceneDIContainer.makeLoginFlowCoordinator(navigationController: navigationController)
        start(coordinator: flow)
    }
}

extension AppFlowCoordinator: SignInListener {
    func signIn() {
        mainFlowStart()
    }
}

extension AppFlowCoordinator: SignOutListener {
    func signOut() {
        KeyChainService.shared.deleteToken()
        loginFlowStart()
    }
}
    
    


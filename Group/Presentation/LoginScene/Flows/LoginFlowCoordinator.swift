//
//  LoginFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit
import RxSwift

protocol LoginFlowCoordinaotorDependencies {
    func makeLoginViewController(action: LoginAction) -> LoginViewController
    func makeProfileSetupViewController() -> ProfileSetupViewController
}

final class LoginFlowCoordinator: BaseCoordinator {
    
    private let dependencies: LoginFlowCoordinaotorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: LoginFlowCoordinaotorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let action = LoginAction(showProfileView: showProfileView)
        let vc = dependencies.makeLoginViewController(action: action)
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showProfileView() {
        let vc = self.dependencies.makeProfileSetupViewController() // 액션 추가
        self.navigationController.pushViewController(vc, animated: true)
    }
}

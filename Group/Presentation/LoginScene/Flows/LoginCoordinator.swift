//
//  LoginFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit

protocol LoginCoordinaotorDependencies {
    func makeLoginViewController(action: LoginAction) -> LoginViewController
    func makeProfileSetupViewController(action: SignInAction) -> ProfileSetupViewController
}

final class LoginCoordinator: BaseCoordinator {
    
    private let dependencies: LoginCoordinaotorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: LoginCoordinaotorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let action = LoginAction(showProfileView: showProfileView)
        let vc = dependencies.makeLoginViewController(action: action)
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showProfileView() {
        let action = SignInAction(completedSignIn: completedSignIn)
        let vc = self.dependencies.makeProfileSetupViewController(action: action)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    private func completedSignIn() {
        self.navigationController.viewControllers = []
        self.parentCoordinator?.didFinish(coordinator: self)
        (self.parentCoordinator as? SignInListener)?.signIn()
    }
}

//
//  LoginFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit

protocol LoginCoordinaotorDependencies {
    func makeLoginViewController(action: LoginAction) -> LoginViewController
    func makeProfileSetupViewController(action: ProfileSetupAction) -> ProfileSetupViewController
}

final class LoginCoordinator: BaseCoordinator {
    
    private let dependencies: LoginCoordinaotorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: LoginCoordinaotorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let action = LoginAction(logIn: showProfileView)
        let vc = dependencies.makeLoginViewController(action: action)
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showProfileView() {
        let action = ProfileSetupAction(completed: completedSignIn)
        let vc = self.dependencies.makeProfileSetupViewController(action: action)
        self.navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - 로그인 -> 메인 뷰로 들어가기
extension LoginCoordinator {
    private func completedSignIn() {
        fadeOut { [weak self] in
            self?.clearScene()
        }
    }
    
    private func clearScene() {
        self.navigationController.viewControllers = []
        self.parentCoordinator?.didFinish(coordinator: self)
        (self.parentCoordinator as? SignInListener)?.signIn()
    }
    
}

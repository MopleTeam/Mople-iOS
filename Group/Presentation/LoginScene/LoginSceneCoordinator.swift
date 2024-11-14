//
//  LoginFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit

protocol LoginSceneDependencies {
    func makeLoginViewController(action: LoginAction) -> LoginViewController
    func makeProfileCreateViewController(action: ProfileSetupAction) -> ProfileCreateViewController
}

final class LoginSceneCoordinator: BaseCoordinator {
    
    private let dependencies: LoginSceneDependencies
    
    init(navigationController: UINavigationController,
         dependencies: LoginSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let action = LoginAction(logIn: showProfileSetupView)
        let vc = dependencies.makeLoginViewController(action: action)
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func showProfileSetupView() {
        let action = ProfileSetupAction(completed: completedSignIn)
        let vc = self.dependencies.makeProfileCreateViewController(action: action)
        self.navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - 로그인 -> 메인 뷰로 들어가기
extension LoginSceneCoordinator {
    
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

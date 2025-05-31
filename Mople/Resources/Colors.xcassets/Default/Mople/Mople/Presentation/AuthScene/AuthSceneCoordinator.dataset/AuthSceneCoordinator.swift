//
//  LoginFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit

protocol AuthFlowCoordination: AnyObject {
    func pushSignUpView(_ socialInfo: SocialInfo)
    func presentMainFlow()
}

final class AuthSceneCoordinator: BaseCoordinator, AuthFlowCoordination {
    
    private let dependencies: AUthSceneDependencies
    
    init(navigationController: AppNaviViewController,
         dependencies: AUthSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = dependencies.makeSignInViewController(coordinator: self)
        self.pushWithTracking(vc, animated: false)
    }
}

// MARK: - View
extension AuthSceneCoordinator {
    func pushSignUpView(_ socialInfo: SocialInfo) {
        let vc = self.dependencies.makeSignUpViewController(socialInfo: socialInfo,
                                                            coordinator: self)
        self.pushWithTracking(vc, animated: true)
    }
}

// MARK: - Flow
extension AuthSceneCoordinator: SignUpCoordination {
    
    func presentMainFlow() {
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

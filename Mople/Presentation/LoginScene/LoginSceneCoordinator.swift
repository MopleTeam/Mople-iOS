//
//  LoginFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit

protocol LoginSceneDependencies {
    func makeLoginViewController(action: SignInAction) -> SignInViewController
    func makeSignUpViewController(socialAccountInfo: SocialAccountInfo,
                                         action: SignUpAction) -> SignUpViewController
}

final class LoginSceneCoordinator: BaseCoordinator {
    
    private let dependencies: LoginSceneDependencies
    
    init(navigationController: UINavigationController,
         dependencies: LoginSceneDependencies) {
        print(#function, #line, "LifeCycle Test LoginSceneCoordinator Created" )
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test LoginSceneCoordinator Deinit" )
    }
    
    override func start() {
        let action = SignInAction(toProfileSetup: showProfileSetupView,
                                 toMain: completedSignIn)
        let vc = dependencies.makeLoginViewController(action: action)
        
        navigationController.pushViewController(vc, animated: false)
    }
}

// MARK: - 프로필 뷰 전환
extension LoginSceneCoordinator {
    private func showProfileSetupView(_ socialAccountInfo: SocialAccountInfo) {
        let action = SignUpAction(completed: completedSignIn)
        let vc = self.dependencies.makeSignUpViewController(socialAccountInfo: socialAccountInfo,
                                                                   action: action)
        self.navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - 메인 뷰 전환
extension LoginSceneCoordinator {
    
    private func completedSignIn() {
        print(#function, #line, "# 30 로그인 성공" )
        fadeOut { [weak self] in
            self?.clearScene()
        }
    }
    
    private func clearScene() {
        print(#function, #line, "# 30 메인뷰로 이동" )
        self.navigationController.viewControllers = []
        self.parentCoordinator?.didFinish(coordinator: self)
        (self.parentCoordinator as? SignInListener)?.signIn()
    }
    
}

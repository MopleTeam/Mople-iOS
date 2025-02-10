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
        navigationController.pushViewController(vc, animated: false)
    }
}

// MARK: - 프로필 뷰 전환
extension AuthSceneCoordinator {
    func pushSignUpView(_ socialInfo: SocialInfo) {
        let vc = self.dependencies.makeSignUpViewController(socialInfo: socialInfo,
                                                            coordinator: self)
        self.navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - 메인 뷰 전환
extension AuthSceneCoordinator: SignUpCoordination {
    
    func presentMainFlow() {
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

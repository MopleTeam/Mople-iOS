//
//  TapBarCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol SignOut {
    func singOut()
}

protocol TabBarCoordinaotorDependencies {
    func getMainFlowCoordinator() -> [BaseCoordinator]
}

final class TabBarCoordinator: BaseCoordinator {
    
    private let dependencies: TabBarCoordinaotorDependencies
    private let tabBarController: UITabBarController
 
    init(navigationController: UINavigationController,
         dependencies: TabBarCoordinaotorDependencies) {
        self.dependencies = dependencies
        self.tabBarController = CustomTabBarController()
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let coordinators = dependencies.getMainFlowCoordinator()
        coordinators.forEach {
            $0.navigationController.navigationBar.isHidden = true
            self.start(coordinator: $0)
        }
        let viewControllers = coordinators.map { $0.navigationController }
        tabBarController.setViewControllers(viewControllers, animated: true)
        
        navigationController.pushViewController(tabBarController, animated: true)
    }
}

// MARK: - 로그아웃 -> 로그인 뷰로 돌아가기
extension TabBarCoordinator: SignOut {
    
    func singOut() {
        fadeOut { [weak self] in
            self?.clearScene()
        }
    }
    
    private func clearScene() {
        self.childCoordinators.forEach {
            $0.navigationController.viewControllers = []
            self.didFinish(coordinator: $0)
        }
        
        self.childCoordinators.removeAll()
        self.tabBarController.viewControllers?.removeAll()
        
        self.navigationController.viewControllers = []
        self.parentCoordinator?.didFinish(coordinator: self)
        (self.parentCoordinator as? SignOutListener)?.signOut()
    }
}


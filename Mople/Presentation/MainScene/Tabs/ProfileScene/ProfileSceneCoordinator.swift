//
//  ProfileFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol ProfileSceneDependencies {
    func makeProfileViewController(action: ProfileViewAction) -> ProfileViewController
    func makeNotifyViewController() -> NotifyViewController
    func makePolicyViewController() -> PolicyViewController
}

final class ProfileSceneCoordinator: BaseCoordinator {
    private let dependencies: ProfileSceneDependencies
    
    init(navigationController: UINavigationController,
         dependencies: ProfileSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = dependencies.makeProfileViewController(action: getAccountAction())
        navigationController.pushViewController(vc, animated: false)
    }
}

// MARK: - 뷰 이동
extension ProfileSceneCoordinator {
    private func getAccountAction() -> ProfileViewAction {
        .init(presentEditView: presentEditView(previousProfile:completedAction:),
              presentNotifyView: presentNotifyView,
              presentPolicyView: presentPolicyView,
              logout: logout)
    }
    
    private func presentEditView(previousProfile: ProfileInfo, completedAction: (() -> Void)?) {
        (self.parentCoordinator as? AccountAction)?.editProfile(previousProfile, completedAction)
    }
    
    private func presentNotifyView() {
        let notifyView = dependencies.makeNotifyViewController()
        self.navigationController.pushViewController(notifyView, animated: true)
    }
    
    private func presentPolicyView() {
        let policyView = dependencies.makePolicyViewController()
        self.navigationController.pushViewController(policyView, animated: true)
    }
    
    private func logout() {
        (self.parentCoordinator as? AccountAction)?.signOut()
    }
}




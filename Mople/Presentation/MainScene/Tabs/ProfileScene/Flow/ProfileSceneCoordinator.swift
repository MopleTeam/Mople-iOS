//
//  ProfileFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol ProfileCoordination: AnyObject {
    func presentEditView(previousProfile: UserInfo)
    func presentNotifyView()
    func presentPolicyView()
    func logout()
}

final class ProfileSceneCoordinator: BaseCoordinator, ProfileCoordination {
    
    private let dependencies: ProfileSceneDependencies
    private(set) var profileVC: ProfileViewController?
    
    init(navigationController: UINavigationController,
         dependencies: ProfileSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        profileVC = dependencies.makeProfileViewController(coordinator: self)
        navigationController.pushViewController(profileVC!, animated: false)
    }
}

// MARK: - 뷰 이동
extension ProfileSceneCoordinator {
    
    func presentEditView(previousProfile: UserInfo) {
        let profileEditView = dependencies.makeProfileEditViewController(previousProfile: previousProfile,                                        coordinator: self)
        profileEditView.modalPresentationStyle = .fullScreen
        self.navigationController.present(profileEditView, animated: false)
    }
    
    func presentNotifyView() {
        let notifyView = dependencies.makeNotifyViewController()
        self.navigationController.pushViewController(notifyView, animated: false)
    }
    
    func presentPolicyView() {
        let policyView = dependencies.makePolicyViewController()
        self.navigationController.pushViewController(policyView, animated: false)
    }
    
    func logout() {
        (self.parentCoordinator as? MainCoordination)?.signOut()
    }
}






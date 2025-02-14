//
//  ProfileFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol ProfileCoordination: AnyObject {
    func presentEditView(previousProfile: UserInfo)
    func pushNotifyView()
    func pushPolicyView()
    func logout()
}

final class ProfileFlowCoordinator: BaseCoordinator, ProfileCoordination {
    
    private let dependencies: ProfileSceneDependencies
    private var profileVC: ProfileViewController?
    
    init(navigationController: AppNaviViewController,
         dependencies: ProfileSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        profileVC = dependencies.makeProfileViewController(coordinator: self)
        navigationController.pushViewController(profileVC!, animated: false)
    }
}

// MARK: - Push
extension ProfileFlowCoordinator {
    func pushNotifyView() {
        let notifyView = dependencies.makeNotifyViewController()
        self.navigationController.pushViewController(notifyView, animated: false)
    }
    
    func pushPolicyView() {
        let policyView = dependencies.makePolicyViewController()
        self.navigationController.pushViewController(policyView, animated: false)
    }
    
    func logout() {
        (self.parentCoordinator as? MainCoordination)?.signOut()
    }
}

// MARK: - Present
extension ProfileFlowCoordinator: ProfileEditViewCoordinator {
    func presentEditView(previousProfile: UserInfo) {
        let profileEditView = dependencies.makeProfileEditViewController(previousProfile: previousProfile,
                                                                         coordinator: self)
        self.navigationController.presentWithTransition(profileEditView)
    }
    
    func complete() {
        profileVC?.fetchProfile()
        dismiss()
    }
}




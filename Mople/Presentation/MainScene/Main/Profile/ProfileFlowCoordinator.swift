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
    func endMainFlow()
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
        self.push(profileVC!, animated: false)
    }
}

// MARK: - Notify View
extension ProfileFlowCoordinator: NotifySubscribeCoordination {
    func pushNotifyView() {
        let notifyView = dependencies.makeNotifyViewController(coordinator: self)
        self.pushWithTracking(notifyView, animated: true)
    }
}

// MARK: - Policy View
extension ProfileFlowCoordinator {
    func pushPolicyView() {
        let policyView = dependencies.makePolicyViewController()
        self.pushWithTracking(policyView, animated: true)
    }
}

// MARK: - Profile Edit Flow
extension ProfileFlowCoordinator: ProfileEditViewCoordination {
    func presentEditView(previousProfile: UserInfo) {
        let profileEditView = dependencies.makeProfileEditViewController(previousProfile: previousProfile,
                                                                         coordinator: self)
        self.presentWithTracking(profileEditView)
    }
}

// MARK: - End Main Flow
extension ProfileFlowCoordinator {
    func endMainFlow() {
        (self.parentCoordinator as? MainCoordination)?.startLoginFlow()
    }
}




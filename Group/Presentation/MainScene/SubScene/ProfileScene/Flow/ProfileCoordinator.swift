//
//  ProfileFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol ProfileCoordinatorDependencies {
    func makeProfileViewController(action: accountAction) -> ProfileViewController
    func makeProfileEditViewController(profile: Profile,
                                       action: ProfileSetupAction) -> ProfileEditViewController
}

final class ProfileCoordinator: BaseCoordinator {
    private let dependencies: ProfileCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: ProfileCoordinatorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = dependencies.makeProfileViewController(action: accountAction(editProfile: presentEditView(profile:)))
        
        navigationController.pushViewController(vc, animated: false)
    }
}

extension ProfileCoordinator {
    private func presentEditView(profile: Profile) {
        guard let customNavi = navigationController as? MainNavigationController else { return }
        let profileSetupView = dependencies.makeProfileEditViewController(profile: profile,
                                                                          action: .init(completed: editCompleted))
        profileSetupView.modalPresentationStyle = .custom
        profileSetupView.transitioningDelegate = customNavi
        customNavi.present(profileSetupView, animated: true, completion: nil)
    }
    
    private func editCompleted() {
        
    }
}





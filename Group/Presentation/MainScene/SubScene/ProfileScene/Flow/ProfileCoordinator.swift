//
//  ProfileFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol ProfileCoordinatorDependencies {
    func makeProfileViewController(action: accountAction) -> ProfileViewController
    func makeProfileEditViewController(updateModel: ProfileUpdateModel) -> ProfileEditViewController
}

final class ProfileCoordinator: BaseCoordinator {
    private let dependencies: ProfileCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: ProfileCoordinatorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = dependencies.makeProfileViewController(action: accountAction(presentEditView: presentEditView(updateModel:)))
        
        navigationController.pushViewController(vc, animated: false)
    }
}

extension ProfileCoordinator {
    private func presentEditView(updateModel: ProfileUpdateModel) {
        guard let customNavi = navigationController as? MainNavigationController else { return }
        let profileSetupView = dependencies.makeProfileEditViewController(updateModel: updateModel)
        profileSetupView.modalPresentationStyle = .custom
        profileSetupView.transitioningDelegate = customNavi
        customNavi.present(profileSetupView, animated: true, completion: nil)
    }
}





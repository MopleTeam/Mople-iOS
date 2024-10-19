//
//  ProfileSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

final class ProfileSceneDIContainer: ProfileCoordinatorDependencies {
 
    let apiDataTransferService: DataTransferService

    init(apiDataTransferService: DataTransferService) {
        self.apiDataTransferService = apiDataTransferService
    }
    
    func makeProfileFlowCoordinator(navigationController: UINavigationController) -> ProfileCoordinator {
        let flow = ProfileCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
    
    func makeProfileViewController(action: accountAction) -> ProfileViewController {
        return ProfileViewController(reactor: makeProfileViewReactor(action: action))
    }
    
    func makeProfileEditViewController(updateModel: ProfileUpdateModel) -> ProfileEditViewController {
        return ProfileEditViewController(profile: updateModel.currentProfile,
                                         reactor: makeProfileEditViewReactor(action: updateModel.completedAction))
    }
    
    private func makeProfileViewReactor(action: accountAction) -> ProfileViewReactor {
        return ProfileViewReactor(editProfileUseCase: EditProfileMock(),
                                  accountAction: action)
    }
    
    private func makeProfileEditViewReactor(action: ProfileSetupAction) -> ProfileSetupViewReactor {
        return .init(profileSetupUseCase: ProfileSetupMock(),
                     completedAction: action)
    }
}

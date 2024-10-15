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
        return ProfileViewController(title: "마이페이지",
                                     reactor: makeProfileViewReactor(action: action))
    }
    
    func makeProfileEditViewController(profile: Profile,
                                       action: ProfileSetupAction) -> ProfileEditViewController {
        return ProfileEditViewController(profile: profile,
                                         title: "프로필 수정",
                                         reactor: makeProfileEditViewReactor(action: action))
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

//
//  ProfileSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

final class ProfileSceneDIContainer: ProfileCoordinatorDependencies {
 
    let appNetworkService: AppNetWorkService

    init(appNetworkService: AppNetWorkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeProfileFlowCoordinator(navigationController: UINavigationController) -> ProfileCoordinator {
        let flow = ProfileCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
}

// MARK: - 프로필 Flow
extension ProfileSceneDIContainer {
    func makeProfileViewController(action: ProfileViewAction) -> ProfileViewController {
        return ProfileViewController(reactor: makeProfileViewReactor(action: action))
    }
    
    private func makeProfileViewReactor(action: ProfileViewAction) -> ProfileViewReactor {
        return ProfileViewReactor(editProfileUseCase: FetchProfileMock(),
                                  viewAction: action)
    }
}

// MARK: - 프로필 편집 Flow
extension ProfileSceneDIContainer {
    func makeProfileEditViewController(updateModel: ProfileUpdateModel) -> ProfileEditViewController {
        return ProfileEditViewController(profile: updateModel.currentProfile,
                                         reactor: makeProfileEditViewReactor(action: updateModel.completedAction))
    }
    
    private func makeProfileEditViewReactor(action: ProfileSetupAction) -> ProfileSetupViewReactor {
        return .init(profileRepository: ProfileRepositoryMock(),
                     completedAction: action)
    }
}

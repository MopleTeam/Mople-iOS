//
//  ProfileSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol ProfileSceneDependencies {
    func makeProfileViewController(coordinator: ProfileCoordination) -> ProfileViewController
    func makeProfileEditViewController(previousProfile: UserInfo,
                                       coordinator: ProfileEditCoordination) -> ProfileEditViewController
    func makeNotifyViewController() -> NotifyViewController
    func makePolicyViewController() -> PolicyViewController
}

final class ProfileSceneDIContainer: ProfileSceneDependencies {
 
    let appNetworkService: AppNetworkService
    let commonDependencies: CommonDependencies

    init(appNetworkService: AppNetworkService,
         commonDependencies: CommonDependencies) {
        self.appNetworkService = appNetworkService
        self.commonDependencies = commonDependencies
    }
    
    func makeSetupFlowCoordinator(navigationController: UINavigationController) -> ProfileSceneCoordinator {
        let flow = ProfileSceneCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
}

// MARK: - 프로필 View
extension ProfileSceneDIContainer {
    func makeProfileViewController(coordinator: ProfileCoordination) -> ProfileViewController {
        let title = TextStyle.Profile.title
        return ProfileViewController(title: title,
                                     reactor: makeProfileViewReactor(coordinator: coordinator))
    }
    
    private func makeProfileViewReactor(coordinator: ProfileCoordination) -> ProfileViewReactor {
        return ProfileViewReactor(coordinator: coordinator)
    }
}

// MARK: - 프로필 편집 View
extension ProfileSceneDIContainer {
    func makeProfileEditViewController(previousProfile: UserInfo,
                                       coordinator: ProfileEditCoordination) -> ProfileEditViewController {
        return .init(profile: previousProfile,
                     profileSetupReactor: commonDependencies.makeProfileSetupReactor(),
                     editProfileReactor: makeProfileEditViewReactor(coordinator:                                        coordinator))
    }
    
    private func makeProfileEditViewReactor(coordinator: ProfileEditCoordination) -> ProfileEditViewReactor {
        return .init(profileEditUseCase: ProfileEditMock(),
                     coordinator: coordinator)
    }
    
    private func makeProfileEditUseCase() -> ProfileEdit {
        return ProfileEditUseCase(imageUploadRepo: makeImageUploadRepo(),
                                  profileEditRepo: makeProfileEditRepo())
    }
    
    private func makeImageUploadRepo() -> ImageUploadRepo {
        return DefaultImageUploadRepo(networkServbice: appNetworkService)
    }
    
    private func makeProfileEditRepo() -> ProfileEditRepo {
        return DefaultProfileEditRepo(networkService: appNetworkService)
    }
}

// MARK: - 알림관리 View
extension ProfileSceneDIContainer {
    func makeNotifyViewController() -> NotifyViewController {
        return NotifyViewController()
    }
}

// MARK: - 개인정보 처리방침 View
extension ProfileSceneDIContainer {
    func makePolicyViewController() -> PolicyViewController {
        return PolicyViewController()
    }
}

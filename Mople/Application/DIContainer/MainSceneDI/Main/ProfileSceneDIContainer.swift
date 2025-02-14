//
//  ProfileSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol ProfileSceneDependencies {
    // MARK: - View
    func makeProfileViewController(coordinator: ProfileCoordination) -> ProfileViewController
    func makeProfileEditViewController(previousProfile: UserInfo,
                                       coordinator: ProfileEditViewCoordinator) -> ProfileEditViewController
    func makeNotifyViewController() -> NotifyViewController
    func makePolicyViewController() -> PolicyViewController
}

final class ProfileSceneDIContainer: ProfileSceneDependencies {
 
    let appNetworkService: AppNetworkService
    let commonFacoty: CommonSceneFactory

    init(appNetworkService: AppNetworkService,
         commonFacoty: CommonSceneFactory) {
        self.appNetworkService = appNetworkService
        self.commonFacoty = commonFacoty
    }
    
    func makeSetupFlowCoordinator() -> ProfileFlowCoordinator {
        let navigationController = AppNaviViewController(type: .main)
        navigationController.tabBarItem = .init(title: TextStyle.Tabbar.profile,
                                                image: .person,
                                                selectedImage: nil)
        return ProfileFlowCoordinator(navigationController: navigationController,
                                       dependencies: self)
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
                                       coordinator: ProfileEditViewCoordinator) -> ProfileEditViewController {
        return ProfileEditViewController(
            editProfileReactor: makeProfileEditViewReactor(previousProfile: previousProfile,
                                                           coordinator: coordinator))
    }
    
    private func makeProfileEditViewReactor(previousProfile: UserInfo,
                                            coordinator: ProfileEditViewCoordinator) -> ProfileEditViewReactor {
        return .init(previousProfile: previousProfile,
                     editProfile: makeEditProfileUseCase(),
                     imageUpload: commonFacoty.makeImageUploadUseCase(),
                     validationNickname: commonFacoty.makeDuplicateNicknameUseCase(),
                     photoService: DefaultPhotoService(),
                     coordinator: coordinator)
    }
    
    private func makeEditProfileUseCase() -> EditProfile {
        return EditProfileUseCase(
            userInfoRepo: DefaultUserInfoRepo(networkService: appNetworkService)
        )
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

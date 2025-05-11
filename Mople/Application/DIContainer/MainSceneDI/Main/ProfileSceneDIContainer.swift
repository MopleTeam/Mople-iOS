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
                                       coordinator: ProfileEditViewCoordination) -> ProfileEditViewController
    func makeNotifyViewController(coordinator: NotifySubscribeCoordination) -> NotifySubcribeViewController
    func makePolicyViewController() -> PolicyViewController
}

final class ProfileSceneDIContainer: ProfileSceneDependencies {
 
    let appNetworkService: AppNetworkService
    let commonFacoty: ViewDependencies

    init(appNetworkService: AppNetworkService,
         commonFacoty: ViewDependencies) {
        self.appNetworkService = appNetworkService
        self.commonFacoty = commonFacoty
    }
    
    func makeSetupFlowCoordinator() -> ProfileFlowCoordinator {
        let navigationController = AppNaviViewController(type: .main)
        navigationController.tabBarItem = .init(title: L10n.profile,
                                                image: .person,
                                                selectedImage: nil)
        return ProfileFlowCoordinator(navigationController: navigationController,
                                       dependencies: self)
    }
}

// MARK: - Default View
extension ProfileSceneDIContainer {
    func makeProfileViewController(coordinator: ProfileCoordination) -> ProfileViewController {
        return ProfileViewController(screenName: .profile,
                                     title: L10n.profile,
                                     reactor: makeProfileViewReactor(coordinator: coordinator))
    }
    
    private func makeProfileViewReactor(coordinator: ProfileCoordination) -> ProfileViewReactor {
        return ProfileViewReactor(signOutUseCase: makeSignoutUseCase(),
                                  deleteAccountUseCase: makeDeleteAccountUseCase(),
                                  coordinator: coordinator)
    }
    
    private func makeSignoutUseCase() -> SignOut {
        return SignOutUseCase(repo: makeAuthRepo())
    }
    
    private func makeDeleteAccountUseCase() -> DeleteAccount {
        return DeleteAccountUseCase(repo: makeAuthRepo())
    }
    
    private func makeAuthRepo() -> AuthenticationRepo {
        return DefaultAuthenticationRepo(networkService: appNetworkService)
    }
}

// MARK: - View
extension ProfileSceneDIContainer {
    
    // MARK: - 프로필 수정
    func makeProfileEditViewController(previousProfile: UserInfo,
                                       coordinator: ProfileEditViewCoordination) -> ProfileEditViewController {
        return ProfileEditViewController(
            screenName: .profile_write,
            title: L10n.editProfile,
            editProfileReactor: makeProfileEditViewReactor(previousProfile: previousProfile,
                                                           coordinator: coordinator))
    }
    
    private func makeProfileEditViewReactor(previousProfile: UserInfo,
                                            coordinator: ProfileEditViewCoordination) -> ProfileEditViewReactor {
        let userInfoRepo = DefaultUserInfoRepo(networkService: appNetworkService)
        let nicknameRepo = DefaultNicknameManagerRepo(networkService: appNetworkService)
        let imageRepo = DefaultImageUploadRepo(networkService: appNetworkService)
        return .init(previousProfile: previousProfile,
                     editProfile: makeEditProfileUseCase(repo: userInfoRepo),
                     imageUpload: makeImageUploadUseCase(repo: imageRepo),
                     validationNickname: makeDuplicateNicknameUseCase(repo: nicknameRepo),
                     photoService: DefaultPhotoService(),
                     coordinator: coordinator)
    }
    
    private func makeEditProfileUseCase(repo: UserInfoRepo) -> EditProfile {
        return EditProfileUseCase(userInfoRepo: repo)
    }
    
    private func makeDuplicateNicknameUseCase(repo: NicknameRepo) -> CheckDuplicateNickname {
        return CheckDuplicateNicknameUseCase(duplicateCheckRepo: repo)
    }
    
    private func makeImageUploadUseCase(repo: ImageUploadRepo) -> ImageUpload {
        return ImageUploadUseCase(imageUploadRepo: repo)
    }
    
    // MARK: - 알림 관리
    func makeNotifyViewController(coordinator: NotifySubscribeCoordination) -> NotifySubcribeViewController {
        return NotifySubcribeViewController(
            screenName: .notification_setting,
            title: L10n.Profile.notify,
            reactor: makeNotifySubscribeReactor(coordinator: coordinator)
        )
    }
    
    private func makeNotifySubscribeReactor(coordinator: NotifySubscribeCoordination) -> NotifySubscribeViewReactor {
        let repo = DefaultNotifySubscribeRepo(networkService: appNetworkService)
        return .init(fetchNotifyState: makeFetchNotifyState(repo: repo),
                     subscribeNotify: makeSubscribeNotify(repo: repo),
                     uploadFCMTokcn: makeUploadFCMTokenUseCase(),
                     notificationService: makeNotifyService(),
                     coordinator: coordinator)
    }
    
    private func makeFetchNotifyState(repo: NotifySubscribeRepo) -> FetchNotifyState {
        return FetchNotifyStateUseCase(repo: repo)
    }
    
    private func makeSubscribeNotify(repo: NotifySubscribeRepo) -> SubscribeNotify {
        return SubscribeNotifyUseCase(repo: repo)
    }
    
    private func makeUploadFCMTokenUseCase() -> UploadFCMToken {
        let fcmTokenRepo = DefaultFCMTokenRepo(networkService: appNetworkService)
        return UploadFCMTokenUseCase(repo: fcmTokenRepo)
    }
    
    private func makeNotifyService() -> NotificationService {
        return DefaultNotificationService()
    }
    
    // MARK: - 개인정보 처리방침 View
    func makePolicyViewController() -> PolicyViewController {
        return .init(screenName: .privacy_policy,
                     title: L10n.Profile.policy)
    }
}

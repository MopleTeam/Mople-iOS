//
//  ProfileSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import SwiftUI

protocol ProfileSceneDependencies {
    // MARK: - View
    func makeProfileViewController(coordinator: ProfileCoordination) -> ProfileViewController
    func makeProfileImageViewController(imagePath: String?) -> PhotoBookViewController
    func makeProfileEditViewController(previousProfile: UserInfo,
                                       coordinator: ProfileEditViewCoordination) -> ProfileEditViewController
    func makeNotifyViewController(coordinator: NotifySubscribeCoordination) -> NotifySubcribeViewController
    func makeThemeSettingViewController() -> UIViewController
    func makePolicyViewController() -> PolicyViewController

    // MARK: - SwiftUI (Transfer Meet)
    func makeTransferMeetFlow() -> BaseCoordinator
}

final class ProfileSceneDIContainer: BaseContainer, ProfileSceneDependencies {
    
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
                                  fetchMyHostMeetsUseCase: makeFetchMyHostMeetsUseCase(),
                                  coordinator: coordinator)
    }
    
    private func makeSignoutUseCase() -> SignOut {
        #if DEV
        return MockDataManager.resolve(SignOutUseCase(repo: makeAuthRepo()) as SignOut, mock: MockSignOutUseCase())
        #else
        return SignOutUseCase(repo: makeAuthRepo())
        #endif
    }
    
    private func makeDeleteAccountUseCase() -> DeleteAccount {
        #if DEV
        return MockDataManager.resolve(DeleteAccountUseCase(repo: makeAuthRepo()) as DeleteAccount, mock: MockDeleteAccountUseCase())
        #else
        return DeleteAccountUseCase(repo: makeAuthRepo())
        #endif
    }
    
    private func makeFetchMyHostMeetsUseCase() -> FetchMyHostMeets {
        #if DEV
        return MockDataManager.resolve(FetchMyHostMeetsUseCase(repo: makeMeetRepo()) as FetchMyHostMeets, mock: MockFetchMyHostMeetsUseCase())
        #else
        return FetchMyHostMeetsUseCase(repo: makeMeetRepo())
        #endif
    }
    
    private func makeAuthRepo() -> AuthenticationRepo {
        return DefaultAuthenticationRepo(networkService: appNetworkService)
    }
    
    private func makeMeetRepo() -> MeetRepo {
        return DefaultMeetRepo(networkService: appNetworkService)
    }
}

// MARK: - View
extension ProfileSceneDIContainer {
    
    // MARK: - 이미지 뷰
    func makeProfileImageViewController(imagePath: String?) -> PhotoBookViewController {
        let imagePaths = [imagePath].compactMap { $0 }
        return commonViewFactory.makePhotoViewController(title: L10n.profile,
                                                         imagePath: imagePaths,
                                                         defaultImageType: .user)
    }
    
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
        #if DEV
        return MockDataManager.resolve(EditProfileUseCase(userInfoRepo: repo) as EditProfile, mock: MockEditProfileUseCase())
        #else
        return EditProfileUseCase(userInfoRepo: repo)
        #endif
    }
    
    private func makeDuplicateNicknameUseCase(repo: NicknameRepo) -> CheckDuplicateNickname {
        #if DEV
        return MockDataManager.resolve(CheckDuplicateNicknameUseCase(duplicateCheckRepo: repo) as CheckDuplicateNickname, mock: MockCheckDuplicateNicknameUseCase())
        #else
        return CheckDuplicateNicknameUseCase(duplicateCheckRepo: repo)
        #endif
    }
    
    private func makeImageUploadUseCase(repo: ImageUploadRepo) -> ImageUpload {
        #if DEV
        return MockDataManager.resolve(ImageUploadUseCase(imageUploadRepo: repo) as ImageUpload, mock: MockImageUploadUseCase())
        #else
        return ImageUploadUseCase(imageUploadRepo: repo)
        #endif
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
        #if DEV
        return MockDataManager.resolve(FetchNotifyStateUseCase(repo: repo) as FetchNotifyState, mock: MockFetchNotifyStateUseCase())
        #else
        return FetchNotifyStateUseCase(repo: repo)
        #endif
    }
    
    private func makeSubscribeNotify(repo: NotifySubscribeRepo) -> SubscribeNotify {
        #if DEV
        return MockDataManager.resolve(SubscribeNotifyUseCase(repo: repo) as SubscribeNotify, mock: MockSubscribeNotifyUseCase())
        #else
        return SubscribeNotifyUseCase(repo: repo)
        #endif
    }
    
    private func makeUploadFCMTokenUseCase() -> UploadFCMToken {
        let fcmTokenRepo = DefaultFCMTokenRepo(networkService: appNetworkService)
        #if DEV
        return MockDataManager.resolve(UploadFCMTokenUseCase(repo: fcmTokenRepo) as UploadFCMToken, mock: MockUploadFCMTokenUseCase())
        #else
        return UploadFCMTokenUseCase(repo: fcmTokenRepo)
        #endif
    }
    
    private func makeNotifyService() -> NotificationService {
        return DefaultNotificationService()
    }
    
    // MARK: - 테마 설정 View (SwiftUI)
    func makeThemeSettingViewController() -> UIViewController {
        let view = ThemeSettingView()
        let hostingController = DismissableHostingController(rootView: view)
        return hostingController
    }

    // MARK: - 개인정보 처리방침 View
    func makePolicyViewController() -> PolicyViewController {
        return .init(screenName: .privacy_policy,
                     title: L10n.Profile.policy)
    }
}

// MARK: - SwiftUI Views (Transfer Meet)
extension ProfileSceneDIContainer {
    
    func makeTransferMeetFlow() -> BaseCoordinator {
        let di = TransferMeetSceneDIContainer(appNetworkService: appNetworkService, commonFactory: commonViewFactory)
        return di.makeFlowCoordinator(onComplete: {
            
        })
    }
}


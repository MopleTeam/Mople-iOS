//
//  LoginSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

protocol AUthSceneDependencies {
    func makeSignInViewController(coordinator: AuthFlowCoordination) -> SignInViewController
    func makeSignUpViewController(socialInfo: SocialInfo,
                                  coordinator: SignUpCoordination) -> SignUpViewController
}

final class AuthSceneDIContainer: BaseContainer {
    
    private lazy var appleLoginService = DefaultAppleLoginService()
    private lazy var kakaoLoginService = DefaultKakaoLoginService()
    
    func makeAuthFlowCoordinator(navigationController: AppNaviViewController) -> AuthSceneCoordinator {
        let flow = AuthSceneCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
}

extension AuthSceneDIContainer: AUthSceneDependencies {
    
    // MARK: - Default View
    func makeSignInViewController(coordinator: AuthFlowCoordination) -> SignInViewController {
        let signInView = SignInViewController(screenName: .sign_in,
                                              reactor: makeSignInViewReacotr(coordinator: coordinator))
        setAppleLoginProvider(signInView)
        return signInView
    }
    
    private func setAppleLoginProvider(_ view: UIViewController) {
        self.appleLoginService.setPresentationContextProvider(view)
    }

    private func makeSignInViewReacotr(coordinator: AuthFlowCoordination) -> SignInViewReactor {
        return SignInViewReactor(signInUseCase: makeSignInUseCase(),
                                 fetchUserInfoUseCase: makeFetchUserInfoUseCase(),
                                 coordinator: coordinator)
    }
    
    private func makeSignInUseCase() -> SignIn {
        let authRepo = DefaultAuthenticationRepo(networkService: appNetworkService)
        return SignInUseCase(appleLoginService: appleLoginService,
                             kakaoLoginService: kakaoLoginService,
                             authenticationRepo: authRepo)
    }
    
    // MARK: - View
    func makeSignUpViewController(socialInfo: SocialInfo,
                                  coordinator: SignUpCoordination) -> SignUpViewController {
        return SignUpViewController(
            screenName: .sign_up,
            signUpReactor: makeSignUpReactor(socialInfo: socialInfo,
                                             coordinator: coordinator))
    }
    
    private func makeSignUpReactor(socialInfo: SocialInfo,
                                   coordinator: SignUpCoordination) -> SignUpViewReactor {
        let nickNameRepo = DefaultNicknameManagerRepo(networkService: appNetworkService)
        return .init(signUpUseCase: makeSignUpUseCase(),
                     imageUploadUseCase: makeImageUploadUseCase(),
                     validationNickname: makeDuplicateNicknameUseCase(repo: nickNameRepo),
                     creationNickname: makeCreationNicknameUseCase(repo: nickNameRepo),
                     fetchUserInfo: makeFetchUserInfoUseCase(),
                     photoService: DefaultPhotoService(),
                     socialInfo: socialInfo,
                     coordinator: coordinator)
    }
    
    private func makeSignUpUseCase() -> SignUp {
        let authRepo = DefaultAuthenticationRepo(networkService: appNetworkService)
        return SignUpUseCase(repo: authRepo)
    }
    
    private func makeImageUploadUseCase() -> ImageUpload {
        let imageRepo = DefaultImageUploadRepo(networkService: appNetworkService)
        return ImageUploadUseCase(imageUploadRepo: imageRepo)
    }
    
    private func makeCreationNicknameUseCase(repo: NicknameRepo) -> CreationNickname {
        return CreationNicknameUseCase(nickNameRepo: repo)
    }
    
    private func makeDuplicateNicknameUseCase(repo: NicknameRepo) -> CheckDuplicateNickname {
        return CheckDuplicateNicknameUseCase(duplicateCheckRepo: repo)
    }
}

// MARK: - Common UseCase
extension AuthSceneDIContainer {
    private func makeFetchUserInfoUseCase() -> FetchUserInfo {
        let userInfoRepo = DefaultUserInfoRepo(networkService: appNetworkService)
        return FetchUserInfoUseCase(userInfoRepo: userInfoRepo)
    }
}



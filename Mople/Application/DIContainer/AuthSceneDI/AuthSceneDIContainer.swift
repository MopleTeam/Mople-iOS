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
        let loginServices: [LoginPlatform: SocialLoginService] = [
            .apple: appleLoginService,
            .kakao: kakaoLoginService
        ]
        #if DEV
        let useCase = MockDataManager.resolve(
            SignInUseCase(loginServices: loginServices,
                          authenticationRepo: authRepo) as SignIn,
            mock: MockSignInUseCase())
        #else
        let useCase = SignInUseCase(loginServices: loginServices,
                                     authenticationRepo: authRepo)
        #endif
        return useCase
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
        #if DEV
        let useCase = MockDataManager.resolve(SignUpUseCase(repo: authRepo) as SignUp, mock: MockSignUpUseCase())
        #else
        let useCase = SignUpUseCase(repo: authRepo)
        #endif
        return useCase
    }
    
    private func makeImageUploadUseCase() -> ImageUpload {
        let imageRepo = DefaultImageUploadRepo(networkService: appNetworkService)
        #if DEV
        let useCase = MockDataManager.resolve(ImageUploadUseCase(imageUploadRepo: imageRepo) as ImageUpload, mock: MockImageUploadUseCase())
        #else
        let useCase = ImageUploadUseCase(imageUploadRepo: imageRepo)
        #endif
        return useCase
    }
    
    private func makeCreationNicknameUseCase(repo: NicknameRepo) -> CreationNickname {
        #if DEV
        let useCase = MockDataManager.resolve(CreationNicknameUseCase(nickNameRepo: repo) as CreationNickname, mock: MockCreationNicknameUseCase())
        #else
        let useCase = CreationNicknameUseCase(nickNameRepo: repo)
        #endif
        return useCase
    }
    
    private func makeDuplicateNicknameUseCase(repo: NicknameRepo) -> CheckDuplicateNickname {
        #if DEV
        let useCase = MockDataManager.resolve(CheckDuplicateNicknameUseCase(duplicateCheckRepo: repo) as CheckDuplicateNickname, mock: MockCheckDuplicateNicknameUseCase())
        #else
        let useCase = CheckDuplicateNicknameUseCase(duplicateCheckRepo: repo)
        #endif
        return useCase
    }
}

// MARK: - Common UseCase
extension AuthSceneDIContainer {
    private func makeFetchUserInfoUseCase() -> FetchUserInfo {
        let userInfoRepo = DefaultUserInfoRepo(networkService: appNetworkService)
        #if DEV
        let useCase = MockDataManager.resolve(FetchUserInfoUseCase(userInfoRepo: userInfoRepo) as FetchUserInfo, mock: MockFetchUserInfoUseCase())
        #else
        let useCase = FetchUserInfoUseCase(userInfoRepo: userInfoRepo)
        #endif
        return useCase
    }
}



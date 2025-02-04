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
                                  coordinator: AuthFlowCoordination) -> SignUpViewController
}

final class AuthSceneDIContainer: AUthSceneDependencies {
    
    private lazy var appleLoginService = DefaultAppleLoginService()
    private lazy var kakaoLoginService = DefaultKakaoLoginService()
    
    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
    }
    
    func makeAuthFlowCoordinator(navigationController: AppNaviViewController) -> AuthSceneCoordinator {
        let flow = AuthSceneCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
}

// MARK: - Login
extension AuthSceneDIContainer {
    
    func makeSignInViewController(coordinator: AuthFlowCoordination) -> SignInViewController {
        let signInView = SignInViewController(reactor: makeSignInViewReacotr(coordinator: coordinator))
        setAppleLoginProvider(signInView)
        return signInView
    }
    
    private func setAppleLoginProvider(_ view: UIViewController) {
        self.appleLoginService.setPresentationContextProvider(view)
    }
    
    // 테스트 모드
    private func makeSignInViewReacotr(coordinator: AuthFlowCoordination) -> SignInViewReactor {
        return SignInViewReactor(signInUseCase: makeSignInUseCase(),
                                 fetchUserInfoUseCase: makeFetchUserInfoUseCase(),
                                 coordinator: coordinator)
    }
    
    private func makeSignInUseCase() -> SignIn {
        return SignInUseCase(appleLoginService: appleLoginService,
                             kakaoLoginService: kakaoLoginService,
                             authenticationRepo: makeAuthenticationRepo())
    }
}

// MARK: - Profile Setup
extension AuthSceneDIContainer {
    func makeSignUpViewController(socialInfo: SocialInfo,
                                  coordinator: AuthFlowCoordination) -> SignUpViewController {
        return SignUpViewController(
            profileSetupReactor: commonFactory
                .makeProfileSetupReactor(profile: nil,
                                         shouldGenerateNickname: true),
            signUpReactor: makeSignUpReactor(socialInfo: socialInfo,
                                             coordinator: coordinator))
    }
    
    private func makeSignUpReactor(socialInfo: SocialInfo,
                                   coordinator: AuthFlowCoordination) -> SignUpViewReactor {
        return .init(imageUploadUseCase: commonFactory.makeImageUploadUseCase(),
                     signUpUseCase: makeSignUpUseCase(socialInfo: socialInfo),
                     fetchUserInfo: makeFetchUserInfoUseCase(),
                     coordinator: coordinator)
    }
    
    private func makeSignUpUseCase(socialInfo: SocialInfo) -> SignUp {
        return SignUpUseCase(authenticationRepo: makeAuthenticationRepo(),
                             platForm: socialInfo)
    }
}

// MARK: - Common
extension AuthSceneDIContainer {
    private func makeFetchUserInfoUseCase() -> FetchUserInfo {
        return FetchUserInfoUseCase(userInfoRepo: makeUserInfoRepo())
    }
    
    private func makeUserInfoRepo() -> UserInfoRepo {
        return DefaultUserInfoRepo(networkService: appNetworkService)
    }
    
    private func makeAuthenticationRepo() -> AuthenticationRepo {
        return DefaultAuthenticationRepo(networkService: appNetworkService)
    }
}

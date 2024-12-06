//
//  LoginSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

final class LoginSceneDIContainer: LoginSceneDependencies {
    
    private lazy var appleLoginService = DefaultAppleLoginService()
    private lazy var kakaoLoginService = DefaultKakaoLoginService()
    
    let appNetworkService: AppNetWorkService
    
    init(appNetworkService: AppNetWorkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeLoginFlowCoordinator(navigationController: UINavigationController) -> LoginSceneCoordinator {
        let flow = LoginSceneCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
}

// MARK: - Login
extension LoginSceneDIContainer {
    
    func makeLoginViewController(action: SignInAction) -> SignInViewController {
        let reacotr = makeLoginViewReacotr(action)
        let loginView = SignInViewController(reactor: reacotr)
        setAppleLoginProvider(loginView)
        return loginView
    }
    
    #warning("Mock")
    private func makeLoginViewReacotr(_ action: SignInAction) -> SignInViewReactor {
        return SignInViewReactor(loginUseCase: makeUserLoginUseCase(),
                                loginAction: action)
    }
    
    private func makeUserLoginUseCase() -> SignIn {
        return SignInUseCase(appleLoginService: appleLoginService,
                             kakaoLoginService: kakaoLoginService,
                             signInRepo: makeSignInRepository())
    }
    
    private func makeSignInRepository() -> SignInRepo {
        return DefaultSignInRepo(networkService: appNetworkService)
    }
    
    private func setAppleLoginProvider(_ view: UIViewController) {
        self.appleLoginService.setPresentationContextProvider(view)
    }
}

// MARK: - Profile Setup
extension LoginSceneDIContainer {
    func makeSignUpViewController(socialAccountInfo: SocialAccountInfo,
                                         action: SignUpAction) -> SignUpViewController {
        return SignUpViewController(profileSetupReactor: makeProfileSetupReactor(),
                                    signUpReactor: makeSignUpReactor(socialAccountInfo: socialAccountInfo,
                                                                     action: action))
    }
    
    private func makeSignUpReactor(socialAccountInfo: SocialAccountInfo,
                                   action: SignUpAction) -> SignUpViewReactor {
        return .init(socialAccountInfo: socialAccountInfo,
                                      signUpUseCase: makeSignUpUseCase(),
                                      completedAction: action)
    }
    
    private func makeSignUpUseCase() -> SignUp {
        return SignUpUseCase(imageUploadRepo: makeImageUploadRepo(),
                             signUpRepo: makeSignUpRepo())
    }

    private func makeImageUploadRepo() -> ImageUploadRepo {
        return DefaultImageUploadRepo(networkServbice: appNetworkService)
    }
    
    private func makeSignUpRepo() -> SignUpRepo {
        return DefaultSignUpRepo(networkService: appNetworkService)
    }
}

// MARK: - 프로필 셋업 Reactor
extension LoginSceneDIContainer {
    private func makeProfileSetupReactor() -> ProfileSetupViewReactor {
        return .init(useCase: makeValidatorNicknameUsecase())
    }
    
    private func makeValidatorNicknameUsecase() -> ValidatorNickname {
        return ValidatorNicknameUseCase(repo: makeNicknameValidatorRepo())
    }
    
    private func makeNicknameValidatorRepo() -> NicknameValidationRepo {
        return DefaultNicknameValidationRepo(networkService: appNetworkService)
    }
}

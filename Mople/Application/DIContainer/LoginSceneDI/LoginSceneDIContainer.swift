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
    
    let appNetworkService: AppNetworkService
    let commonFactory: CommonSceneFactory
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
    }
    
    func makeLoginFlowCoordinator(navigationController: AppNaviViewController) -> LoginSceneCoordinator {
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
                                 fetchUserInfoUseCase: makeFetchUserInfoUserCase(),
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
    func makeSignUpViewController(socialInfo: SocialInfo,
                                         action: SignUpAction) -> SignUpViewController {
        return SignUpViewController(profileSetupReactor: commonFactory.makeProfileSetupReactor(),
                                    signUpReactor: makeSignUpReactor(socialInfo: socialInfo,
                                                                     action: action))
    }
    
    private func makeSignUpReactor(socialInfo: SocialInfo,
                                   action: SignUpAction) -> SignUpViewReactor {
        return .init(socialInfo: socialInfo,
                     signUpUseCase: makeSignUpUseCase(),
                     fetchUserInfoUseCase: makeFetchUserInfoUserCase(),
                     completedAction: action)
    }
    
    private func makeSignUpUseCase() -> SignUp {
        return SignUpUseCase(imageUploadRepo: makeImageUploadRepo(),
                             signUpRepo: makeSignUpRepo())
    }

    private func makeImageUploadRepo() -> ImageUploadRepo {
        return DefaultImageUploadRepo(networkService: appNetworkService)
    }
    
    private func makeSignUpRepo() -> SignUpRepo {
        return DefaultSignUpRepo(networkService: appNetworkService)
    }
}

extension LoginSceneDIContainer {
    private func makeFetchUserInfoUserCase() -> FetchUserInfo {
        return FetchUserInfoUseCase(userInfoRepo: makeUserInfoRepo())
    }
    
    private func makeUserInfoRepo() -> UserInfoRepo  {
        return DefaultUserInfoRepo(networkService: appNetworkService)
    }
}

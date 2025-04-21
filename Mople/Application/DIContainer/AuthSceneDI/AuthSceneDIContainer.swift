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

    private func makeSignInViewReacotr(coordinator: AuthFlowCoordination) -> SignInViewReactor {
        return SignInViewReactor(signInUseCase: makeSignInUseCase(),
                                 fetchUserInfoUseCase: commonFactory.makeFetchUserInfoUseCase(),
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
                                  coordinator: SignUpCoordination) -> SignUpViewController {
        return SignUpViewController(
            signUpReactor: makeSignUpReactor(socialInfo: socialInfo,
                                             coordinator: coordinator))
    }
    
    private func makeSignUpReactor(socialInfo: SocialInfo,
                                   coordinator: SignUpCoordination) -> SignUpViewReactor {
        return .init(signUpUseCase: makeSignUpUseCase(),
                     imageUploadUseCase: commonFactory.makeImageUploadUseCase(),
                     validationNickname: commonFactory.makeDuplicateNicknameUseCase(),
                     creationNickname: makeCreationNicknameUseCase(),
                     fetchUserInfo: commonFactory.makeFetchUserInfoUseCase(),
                     photoService: DefaultPhotoService(),
                     socialInfo: socialInfo,
                     coordinator: coordinator)
    }
    
    private func makeSignUpUseCase() -> SignUp {
        return SignUpUseCase(repo: makeAuthenticationRepo())
    }
    
    private func makeCreationNicknameUseCase() -> CreationNickname {
        let repo = DefaultNicknameManagerRepo(networkService: appNetworkService)
        return CreationNicknameUseCase(nickNameRepo: repo)
    }
}

extension AuthSceneDIContainer {
    private func makeAuthenticationRepo() -> AuthenticationRepo {
        return DefaultAuthenticationRepo(networkService: appNetworkService)
    }
}



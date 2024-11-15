//
//  LoginSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

final class LoginSceneDIContainer: LoginSceneDependencies {
    
    let appleLoginService = DefaultAppleLoginService()
    let kakaoLoginService = DefaultKakaoLoginService()
    
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
    
    func makeLoginViewController(action: LoginAction) -> LoginViewController {
        let reacotr = makeLoginViewReacotr(action)
        let loginView = LoginViewController(reactor: reacotr)
        setAppleLoginProvider(loginView)
        return loginView
    }
    
    #warning("Mock")
    private func makeLoginViewReacotr(_ action: LoginAction) -> LoginViewReactor {
        return LoginViewReactor(loginUseCase: makeUserLoginImpl(),
                                loginAction: action)
    }
    
    private func makeUserLoginImpl() -> UserLogin {
        return UserLoginImpl(appleLoginService: appleLoginService,
                             kakaoLoginService: kakaoLoginService,
                             userRepository: makeLoginRepository())
    }
    
    private func makeLoginRepository() -> LoginRepository {
        return DefaultLoginRepository(networkService: appNetworkService)
    }
    
    private func setAppleLoginProvider(_ view: UIViewController) {
        self.appleLoginService.setPresentationContextProvider(view)
    }
}

// MARK: - Profile Setup
extension LoginSceneDIContainer {
    func makeProfileCreateViewController(action: ProfileSetupAction) -> ProfileCreateViewController {
        return ProfileCreateViewController(reactor: makeProfileSetupReactor(action))
    }
    
    
    /// Profile Setup 과정에서는 추가로 필요한 비즈니스 로직이 없음으로 ViewModel이 Repository를 직접 사용
    private func makeProfileSetupReactor(_ action: ProfileSetupAction) -> ProfileFormViewReactor {
        return ProfileFormViewReactor(profileRepository: ProfileRepositoryMock(),
                                       completedAction: action)
    }

    private func makeProfileRepository() -> ProfileRepository {
        return DefaultProfileRepository(networkService: appNetworkService)
    }
}

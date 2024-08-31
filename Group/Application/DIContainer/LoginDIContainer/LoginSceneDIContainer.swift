//
//  LoginSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

final class LoginSceneDIContainer: LoginCoordinaotorDependencies {
    
    let apiDataTransferService: DataTransferService
    let appleLoginService: AppleLoginService
    let tokenKeyChainService: KeyChainService
    
    private lazy var groupRepository: GroupRepository = .init(dataTransferService: apiDataTransferService,
                                                              tokenKeyCahinService: tokenKeyChainService)
    
    init(apiDataTransferService: DataTransferService,
         appleLoginService: AppleLoginService,
         tokenKeyChainService: KeyChainService) {
        self.apiDataTransferService = apiDataTransferService
        self.appleLoginService = appleLoginService
        self.tokenKeyChainService = tokenKeyChainService
    }
    
    func makeLoginFlowCoordinator(navigationController: UINavigationController) -> LoginCoordinator {
        let flow = LoginCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
}

// MARK: - Apple Login
extension LoginSceneDIContainer {
    
    func makeLoginViewController(action: LoginAction) -> LoginViewController {
        let reacotr = makeLoginViewReacotr(action)
        let loginView = LoginViewController(reactor: reacotr)
        setAppleLoginProvider(loginView)
        return loginView
    }
    
    #warning("Mock")
    private func makeLoginViewReacotr(_ action: LoginAction) -> LoginViewReacotr {
        return LoginViewReacotr(loginUseCase: UserLoginMock(),
                                loginAction: action)
    }
    
    private func makeLoginUseCase() -> UserLogin {
        return UserLoginImpl(appleLoginService: appleLoginService,
                                   userRepository: groupRepository)
    }
    
    private func setAppleLoginProvider(_ view: UIViewController) {
        self.appleLoginService.setPresentationContextProvider(view)
    }
}

// MARK: - Profile Setup
extension LoginSceneDIContainer {
    func makeProfileSetupViewController(action: SignInAction) -> ProfileSetupViewController {
        return ProfileSetupViewController(photoManager: PhotoManager(),
                                          reactor: makeProfileSetupReactor(action))
    }
    
    private func makeProfileSetupReactor(_ action: SignInAction) -> ProfileSetupViewReactor {
        return ProfileSetupViewReactor(profileSetupUseCase: ProfileSetupMock(),
                                       signInAction: action
        )
    }
    
    private func makeProfileSetup() -> ProfileSetup {
        return ProfileSetupImpl(repository: groupRepository)
    }
}

//
//  LoginSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

final class LoginSceneDIContainer: LoginFlowCoordinaotorDependencies {
    
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
    
    func makeLoginFlowCoordinator(navigationController: UINavigationController) -> LoginFlowCoordinator {
        let flow = LoginFlowCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
}

// MARK: - Apple Login
extension LoginSceneDIContainer {
    
    func makeLoginViewController(action: LoginViewModelAction) -> LoginViewController {
        let viewModel = makeLoginViewModel(action)
        let loginView = LoginViewController(with: viewModel)
        setAppleLoginProvider(loginView)
        return loginView
    }
    
    private func makeLoginViewModel(_ action: LoginViewModelAction) -> LoginViewModel {
        return DefaultLoginViewModel(loginUseCase: makeLoginUseCase(),
                                     action: action)
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
    func makeProfileSetupViewController() -> ProfileSetupViewController {
        return ProfileSetupViewController(photoManager: PhotoManager(),
                                          profileSetupReactor: makeProfileSetupReactor())
    }
    
    private func makeProfileSetupReactor() -> ProfileSetupViewModel {
        return ProfileSetupViewModel(profileSetup: makeProfileSetup())
    }
    
    private func makeProfileSetup() -> ProfileSetup {
        return ProfileSetupImpl(repository: groupRepository)
    }
}

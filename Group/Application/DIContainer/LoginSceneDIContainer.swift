//
//  LoginSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

final class LoginSceneDIContainer: LoginFlowCoordinaotorDependencies {
    
    let apiDataTransferService: DataTransferService
    
    let appleLoginService: AppleLoginService = DefaultAppleLoginService()
    let tokenKeyChainService: KeyChainService = TokenKeyChain()
    
    
    init(apiDataTransferService: DataTransferService) {
        self.apiDataTransferService = apiDataTransferService
    }

    func makeLoginViewController(action: LoginViewModelAction) -> LoginViewController {
        let viewModel = makeLoginViewModel(action)
        let loginView = LoginViewController.create(with: viewModel)
        setAppleLoginProvider(loginView)
        return loginView
    }
    
    private func setAppleLoginProvider(_ view: UIViewController) {
        self.appleLoginService.setPresentationContextProvider(view)
    }
    
    private func makeLoginUseCase() -> LoginUseCase {
        return DefaultLoginUseCase(appleLoginService: appleLoginService,
                                   userRepository: makeUserRepository())
    }
    
    private func makeLoginViewModel(_ action: LoginViewModelAction) -> LoginViewModel {
        return DefaultLoginViewModel(loginUseCase: makeLoginUseCase(), action: action)
    }
    
    func makeLoginFlowCoordinator(navigationController: UINavigationController) -> LoginFlowCoordinator {
        let flow = LoginFlowCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
    
    func makeProfileSetupViewController() -> ProfileSetupViewController {
        return ProfileSetupViewController()
    }
    
    private func makeUserRepository() -> UserRepository {
        DefaultGroupRepository(dataTransferService: apiDataTransferService,
                               tokenKeyCahinService: tokenKeyChainService)
    }
    
}

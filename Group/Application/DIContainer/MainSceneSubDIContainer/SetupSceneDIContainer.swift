//
//  ProfileSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

final class SetupSceneDIContainer: SetupCoordinatorDependencies {
 
    let appNetworkService: AppNetWorkService

    init(appNetworkService: AppNetWorkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeSetupFlowCoordinator(navigationController: UINavigationController) -> SetupCoordinator {
        let flow = SetupCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
}

// MARK: - 프로필 Flow
extension SetupSceneDIContainer {
    func makeSetupController(action: ProfileViewAction) -> SetupViewController {
        return SetupViewController(reactor: makeSetupViewReactor(action: action))
    }
    
    private func makeSetupViewReactor(action: ProfileViewAction) -> SetupViewReactor {
        return SetupViewReactor(editProfileUseCase: FetchProfileMock(),
                                  viewAction: action)
    }
}

// MARK: - 프로필 편집 Flow
extension SetupSceneDIContainer {
    func makeProfileEditViewController(updateModel: ProfileUpdateModel) -> ProfileEditViewController {
        return ProfileEditViewController(profile: updateModel.currentProfile,
                                         reactor: makeProfileEditViewReactor(action: updateModel.completedAction))
    }
    
    private func makeProfileEditViewReactor(action: ProfileSetupAction) -> ProfileSetupViewReactor {
        return .init(profileRepository: ProfileRepositoryMock(),
                     completedAction: action)
    }
}

// MARK: - 알림관리 Flow
extension SetupSceneDIContainer {
    func makeNotifyViewController() -> NotifyViewController {
        return NotifyViewController()
    }
}

// MARK: - 개인정보 처리방침 Flow
extension SetupSceneDIContainer {
    func makePolicyViewController() -> PolicyViewController {
        return PolicyViewController()
    }
}

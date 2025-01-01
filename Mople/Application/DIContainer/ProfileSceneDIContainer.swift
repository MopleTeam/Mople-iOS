//
//  ProfileSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

final class ProfileSceneDIContainer: ProfileSceneDependencies {
 
    let appNetworkService: AppNetworkService

    init(appNetworkService: AppNetworkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeSetupFlowCoordinator(navigationController: UINavigationController) -> ProfileSceneCoordinator {
        let flow = ProfileSceneCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
}

// MARK: - 프로필 Flow
extension ProfileSceneDIContainer {
    func makeProfileViewController(action: ProfileViewAction) -> ProfileViewController {
        let title = TextStyle.Profile.title
        return ProfileViewController(title: title, reactor: makeSetupViewReactor(action: action))
    }
    
    private func makeSetupViewReactor(action: ProfileViewAction) -> ProfileViewReactor {
        return ProfileViewReactor(fetchProfileIUseCase: FetchProfileMock(),
                                  viewAction: action)
    }
}

// MARK: - 알림관리 Flow
extension ProfileSceneDIContainer {
    func makeNotifyViewController() -> NotifyViewController {
        return NotifyViewController()
    }
}

// MARK: - 개인정보 처리방침 Flow
extension ProfileSceneDIContainer {
    func makePolicyViewController() -> PolicyViewController {
        return PolicyViewController()
    }
}

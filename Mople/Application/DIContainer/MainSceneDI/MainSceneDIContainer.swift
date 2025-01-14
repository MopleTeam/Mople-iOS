//
//  MainSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

typealias MainSceneDependencies = MainTapDependencies

protocol MainTapDependencies {
    func makeHomeFlowCoordinator() -> BaseCoordinator
    func makeMeetListFlowCoordinator() -> BaseCoordinator
    func makeCalendarFlowCoordinator() -> BaseCoordinator
    func makeProfileCoordinator() -> BaseCoordinator
}

final class MainSceneDIContainer: MainSceneDependencies {
    private var FCMTokenManager: FCMTokenManager?

    private let appNetworkService: AppNetworkService
    let commonFactory: CommonSceneFactory

    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory,
         isFirstStart: Bool) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
        makeFCMTokenManager(isFirstStart: isFirstStart)
    }
    
    func makeMainFlowCoordinator(navigationController: AppNaviViewController) -> MainSceneCoordinator {
        let flow = MainSceneCoordinator(navigationController: navigationController,
                                     dependencies: self)
        return flow
    }
}

// MARK: - FCMToken Manager
extension MainSceneDIContainer {
    private func makeFCMTokenManager(isFirstStart: Bool)  {
        FCMTokenManager = .init(repo: makeFCMTokenRepo(),
                                isRefresh: isFirstStart)
    }
    
    private func makeFCMTokenRepo() -> FCMTokenUploadRepo {
        return DefaultFCMTokenRepo(networkService: appNetworkService)
    }
}

// MARK: - Tabbar
extension MainSceneDIContainer {
    func makeHomeFlowCoordinator() -> BaseCoordinator {
        let homeSceneDI = HomeSceneDIContainer(appNetworkService: appNetworkService,
                                               commonFactory: commonFactory)
        return homeSceneDI.makeHomeFlowCoordinator()
    }
    
    // MARK: - 모임 리스트
    func makeMeetListFlowCoordinator() -> BaseCoordinator {
        let meetListSceneDI = MeetListSceneDIConatiner(appNetworkService: appNetworkService,
                                                       commonFactory: commonFactory)
        return meetListSceneDI.makeMeetListFlowCoordinator()
    }
    
    // MARK: - 캘린더
    func makeCalendarFlowCoordinator() -> BaseCoordinator {
        let calendarSceneDI = CalendarSceneDIContainer(appNetworkService: appNetworkService,
                                                       commonFactory: commonFactory)
        return calendarSceneDI.makeCalendarFlowCoordinator()
    }

    // MARK: - 프로필
    func makeProfileCoordinator() -> BaseCoordinator {
        let profileDI = ProfileSceneDIContainer(appNetworkService: appNetworkService,
                                                commonFacoty: commonFactory)
        return profileDI.makeSetupFlowCoordinator()
    }
}

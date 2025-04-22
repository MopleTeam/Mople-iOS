//
//  MainSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

typealias MainSceneDependencies = MainTapDependencies

protocol MainTapDependencies {
    // MARK: - Tabbar Configure
    func makeHomeFlowCoordinator() -> BaseCoordinator
    func makeMeetListFlowCoordinator() -> BaseCoordinator
    func makeCalendarFlowCoordinator() -> BaseCoordinator
    func makeProfileCoordinator() -> BaseCoordinator
    
    // MARK: - NotificationDestination
    func makeNotificationDestination(type: NotificationDestination) -> BaseCoordinator
}

final class MainSceneDIContainer: MainSceneDependencies, LifeCycleLoggable {

    private let isLogin: Bool
    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory

    init(isLogin: Bool,
         appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory) {
        self.isLogin = isLogin
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func makeMainFlowCoordinator(navigationController: AppNaviViewController) -> MainSceneCoordinator {
        let flow = MainSceneCoordinator(navigationController: navigationController,
                                     dependencies: self)
        return flow
    }
}

// MARK: - Tabbar
extension MainSceneDIContainer {
    func makeHomeFlowCoordinator() -> BaseCoordinator {
        let homeSceneDI = HomeSceneDIContainer(isLogin: isLogin,
                                               appNetworkService: appNetworkService,
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

// MARK: - handle NotificationDestination
extension MainSceneDIContainer {
    func makeNotificationDestination(type: NotificationDestination) -> BaseCoordinator {
        switch type {
        case let .meet(id):
            return commonFactory.makeMeetDetailCoordiantor(meetId: id)
        case let .plan(id):
            return commonFactory.makePlanDetailCoordinator(postId: id, type: .plan)
        case let .review(id):
            return commonFactory.makePlanDetailCoordinator(postId: id, type: .review)
        }
    }
}

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
//
//// MARK: - Main Navigation
//extension MainSceneDIContainer {
//    // MARK: - 그룹 생성 화면
//    func makeCreateMeetViewController(coordinator: CreateMeetCoordination) -> CreateMeetViewController {
//        let createGroupVC = CreateMeetViewController(title: TextStyle.CreateGroup.title,
//                                                      reactor: makeCreateMeetViewReactor(coordinator: coordinator))
//        createGroupVC.configureModalPresentation()
//        return createGroupVC
//    }
//    
//    private func makeCreateMeetViewReactor(coordinator: CreateMeetCoordination) -> CreateMeetViewReactor {
//        return .init(createMeetUseCase: makeCreateMeetUseCase(), // CreateGroupMock()
//                     coordinator: coordinator)
//    }
//    
//    private func makeCreateMeetUseCase() -> CreateMeet {
//        return CreateMeetUseCase(imageUploadRepo: makeImageUploadRepo(),
//                                  createMeetRepo: makeCreateMeetRepo())
//    }
//    
//    private func makeImageUploadRepo() -> ImageUploadRepo {
//        return DefaultImageUploadRepo(networkService: appNetworkService)
//    }
//    
//    private func makeCreateMeetRepo() -> CreateMeetRepo {
//        return DefaultCreateMeetRepo(networkService: appNetworkService)
//    }
//    
//    // MARK: - 일정 생성 화면
//    func makePlanCreateCoordinator(meetList: [MeetSummary]) -> BaseCoordinator {
//        let planCreateDI = PlanCreateSceneDIContainer(
//            appNetworkService: appNetworkService,
//            meetList: meetList)
//        return planCreateDI.makePlanCreateFlowCoordinator()
//    }
//    
//    // MARK: - 미팅 상세 뷰
//    func makeMeetDetailCoordinator(meetId: Int) -> BaseCoordinator {
//        let meetDetailDI = MeetDetailSceneDIContainer(appNetworkService: appNetworkService,
//                                                      meetId: meetId)
//        return meetDetailDI.makeMeetDetailCoordinator()
//    }
//    
//    // MARK: - 일정 상세 뷰
//    func makePlanDetailCoordinator(plan: Plan) -> BaseCoordinator {
//        let planDetailDI = PlanDetailSceneDIContainer(appNetworkService: appNetworkService,
//                                                      plan: plan)
//        return planDetailDI.makePlanDetailCoordinator()
//    }
//}

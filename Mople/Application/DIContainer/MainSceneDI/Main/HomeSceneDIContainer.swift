//
//  HomeSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import Foundation

protocol HomeSceneDependencies {
    // MARK: - View
    func makeHomeViewController(coordinator: HomeFlowCoordinator) -> HomeViewController
    func makeMeetCreateViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController
    
    // MARK: - Flow
    func makePlanCreateFlowCoordinator(meetList: [MeetSummary]) -> BaseCoordinator
    func makePlanDetailFlowCoordinator(postId: Int) -> BaseCoordinator
}

final class HomeSceneDIContainer {
        
    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory

    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
    }
    
    func makeHomeFlowCoordinator() -> HomeFlowCoordinator {
        let navi = AppNaviViewController(type: .main)
        navi.tabBarItem = .init(title: TextStyle.Tabbar.home,
                                image: .home,
                                selectedImage: nil)
        return .init(navigationController: navi,
                     dependencies: self)
    }
}

extension HomeSceneDIContainer: HomeSceneDependencies {
    
    // MARK: - 홈 화면
    func makeHomeViewController(coordinator: HomeFlowCoordinator) -> HomeViewController {
        return HomeViewController(reactor: makeHomeViewReactor(coordinator: coordinator))
    }
    
    // 테스트 모드
    private func makeHomeViewReactor(coordinator: HomeFlowCoordinator) -> HomeViewReactor {
        return HomeViewReactor(fetchRecentScheduleUseCase: makeRecentPlanUseCase(),
                               notificationService: DefaultNotificationService(),
                               coordinator: coordinator)
    }
    
    private func makeRecentPlanUseCase() -> FetchRecentPlan {
        return FetchRecentPlanUseCase(recentPlanRepo: makeRecentPlanRepo())
    }
    
    private func makeRecentPlanRepo() -> PlanQueryRepo {
        return DefaultPlanQueryRepo(networkService: appNetworkService)
    }

        
    // MARK: - 그룹 생성 화면
    func makeMeetCreateViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return commonFactory.makeCreateMeetViewController(coordinator: coordinator)
    }
    
    // MARK: - 일정 생성 플로우
    func makePlanCreateFlowCoordinator(meetList: [MeetSummary]) -> BaseCoordinator {
        return commonFactory.makePlanCreateCoordinator(type: .create(meetList))
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailFlowCoordinator(postId: Int) -> BaseCoordinator {
        return commonFactory.makePlanDetailCoordinator(postId: postId, type: .plan)
    }
}

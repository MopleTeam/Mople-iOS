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
    func makeMeetDetailFlowCoordinator(meetId: Int) -> BaseCoordinator
    func makePlanCreateFlowCoordinator(meetList: [MeetSummary],
                                       completionHandler: ((Plan) -> Void)?) -> BaseCoordinator
    func makePlanDetailFlowCoordinator(postId: Int,
                                       type: PostType) -> BaseCoordinator
    func makeNotifyListFlowCoordinator() -> BaseCoordinator
}

final class HomeSceneDIContainer: BaseContainer, HomeSceneDependencies {
        
    func makeHomeFlowCoordinator() -> HomeFlowCoordinator {
        let navi = AppNaviViewController(type: .main)
        navi.tabBarItem = .init(title: L10n.home,
                                image: .home,
                                selectedImage: nil)
        return .init(navigationController: navi,
                     dependencies: self)
    }
}

// MARK: - Default View
extension HomeSceneDIContainer {
    func makeHomeViewController(coordinator: HomeFlowCoordinator) -> HomeViewController {
        let reactor = makeHomeViewReactor(coordinator: coordinator)
        let recentPlanVC = makeRecentPlanViewController(reactor: reactor)
        return HomeViewController(screenName: .home,
                                  reactor: reactor,
                                  recentPlanVC: recentPlanVC)
    }
    
    private func makeHomeViewReactor(coordinator: HomeFlowCoordinator) -> HomeViewReactor {
        return HomeViewReactor(fetchRecentScheduleUseCase: makeRecentPlanUseCase(),
                               coordinator: coordinator)
    }
    
    private func makeRecentPlanUseCase() -> FetchHomeData {
        let repo = DefaultPlanRepo(networkService: appNetworkService)
        return FetchHomeDataUseCase(repo: repo)
    }
    
    private func makeRecentPlanViewController(reactor: HomeViewReactor) -> RecentPlanViewController {
        return RecentPlanViewController(reactor: reactor)
    }
}

// MARK: - View
extension HomeSceneDIContainer {
    
    // MARK: - 모임생성
    func makeMeetCreateViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return commonViewFactory.makeCreateMeetViewController(isFlow: false,
                                                          isEdit: false,
                                                          type: .create,
                                                          coordinator: coordinator)
    }
}

// MARK: - Flow
extension HomeSceneDIContainer {
    
    // MARK: - 일정생성
    func makePlanCreateFlowCoordinator(meetList: [MeetSummary],
                                       completionHandler: ((Plan) -> Void)?) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            commonViewFactory: commonViewFactory,
            type: .newFromMeetList(meetList))
        return planCreateDI.makePlanCreateFlowCoordinator(completionHandler: completionHandler)
    }
    
    // MARK: - 모임 상세 
    func makeMeetDetailFlowCoordinator(meetId: Int) -> BaseCoordinator {
        let meetDetailDI = MeetDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonViewFactory,
                                                      meetId: meetId,
                                                      isJoin: false)
        return meetDetailDI.makeMeetDetailCoordinator()
    }
    
    // MARK: - 일정 상세
    func makePlanDetailFlowCoordinator(postId: Int,
                                       type: PostType) -> BaseCoordinator {
        let planDetailDI = PostDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonViewFactory,
                                                      type: type,
                                                      id: postId)
        return planDetailDI.makePostDetailCoordinator()
    }
    
    // MARK: - 일정 리스트
    func makeNotifyListFlowCoordinator() -> BaseCoordinator {
        let notifyListSceneDI = NotifyListSceneDIContainer(appNetworkService: appNetworkService,
                                                           commonFactory: commonViewFactory)
        return notifyListSceneDI.makeNotifyListCoordinator()
    }
}

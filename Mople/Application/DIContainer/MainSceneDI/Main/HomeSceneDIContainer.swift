//
//  HomeSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import Foundation
import Domain

protocol HomeSceneDependencies {
    // MARK: - View
    func makeHomeViewController(coordinator: HomeFlowCoordinator) -> HomeViewController
    func makeMeetCreateViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController
    
    // MARK: - Flow
    func makeMeetDetailFlowCoordinator(meetId: Int) -> BaseCoordinator
    func makePlanCreateFlowCoordinator(completionHandler: ((Plan) -> Void)?) -> BaseCoordinator
    func makePlanEditFlowCoorinator(plan: Plan) -> BaseCoordinator
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
        #if DEV
        return MockDataManager.resolve(FetchHomeDataUseCase(repo: repo, session: userSession) as FetchHomeData, mock: MockFetchHomeDataUseCase())
        #else
        return FetchHomeDataUseCase(repo: repo, session: userSession)
        #endif
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
    func makePlanCreateFlowCoordinator(completionHandler: ((Plan) -> Void)?) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            commonViewFactory: commonViewFactory,
            userSession: userSession,
            type: .newFromMeetList)
        return planCreateDI.makePlanCreateFlowCoordinator(completionHandler: completionHandler)
    }
    
    // MARK: - 장소 추가
    func makePlanEditFlowCoorinator(plan: Plan) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            commonViewFactory: commonViewFactory,
            userSession: userSession,
            type: .edit(plan))
        return planCreateDI.makePlanCreateFlowCoordinator()
    }
    
    // MARK: - 모임 상세 
    func makeMeetDetailFlowCoordinator(meetId: Int) -> BaseCoordinator {
        let meetDetailDI = MeetDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonViewFactory,
                                                      userSession: userSession,
                                                      meetId: meetId,
                                                      isJoin: false)
        return meetDetailDI.makeMeetDetailCoordinator()
    }
    
    // MARK: - 일정 상세
    func makePlanDetailFlowCoordinator(postId: Int,
                                       type: PostType) -> BaseCoordinator {
        let planDetailDI = PostDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonViewFactory,
                                                      userSession: userSession,
                                                      type: type,
                                                      postId: postId)
        return planDetailDI.makePostDetailCoordinator()
    }
    
    // MARK: - 일정 리스트
    func makeNotifyListFlowCoordinator() -> BaseCoordinator {
        let notifyListSceneDI = NotifyListSceneDIContainer(appNetworkService: appNetworkService,
                                                           commonFactory: commonViewFactory,
                                                           userSession: userSession)
        return notifyListSceneDI.makeNotifyListCoordinator()
    }
}

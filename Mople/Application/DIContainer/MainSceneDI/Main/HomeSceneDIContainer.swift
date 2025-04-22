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
                                       type: PlanDetailType) -> BaseCoordinator
    func makeNotifyListFlowCoordinator() -> BaseCoordinator
}

final class HomeSceneDIContainer {
        
    private let isLogin: Bool
    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory

    init(isLogin: Bool,
         appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory) {
        self.isLogin = isLogin
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
    
    // MARK: - 기본 화면
    func makeHomeViewController(coordinator: HomeFlowCoordinator) -> HomeViewController {
        let parentVC = HomeViewController(reactor: makeHomeViewReactor(coordinator: coordinator))
        addChildVC(parentVC: parentVC)
        return parentVC
    }
    
    private func makeHomeViewReactor(coordinator: HomeFlowCoordinator) -> HomeViewReactor {
        return HomeViewReactor(isLogin: isLogin,
                               uploadFCMTokcnUseCase: makeUploadFCMTokenUseCase(),
                               fetchRecentScheduleUseCase: makeRecentPlanUseCase(),
                               notificationService: DefaultNotificationService(),
                               coordinator: coordinator)
    }
    
    private func makeUploadFCMTokenUseCase() -> UploadFCMToken {
        let repo = DefaultFCMTokenRepo(networkService: appNetworkService)
        return UploadFCMTokenUseCase(repo: repo)
    }
    
    private func makeRecentPlanUseCase() -> FetchHomeData {
        let repo = DefaultPlanRepo(networkService: appNetworkService)
        return FetchHomeDataUseCase(repo: repo)
    }
    
    private func addChildVC(parentVC: HomeViewController) {
        let recentPlanVC = HomePlanCollectionViewController(reactor: parentVC.homeReactor)
        parentVC.add(child: recentPlanVC,
                     container: parentVC.recentPlanContainerView)
    }
    
    // MARK: - 뷰 이동
    func makeMeetCreateViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return commonFactory.makeCreateMeetViewController(isFlow: false,
                                                          isEdit: false,
                                                          type: .create,
                                                          coordinator: coordinator)
    }
    
    // MARK: - 플로우 이동
    /// 모임생성 플로우 생성
    func makeMeetDetailFlowCoordinator(meetId: Int) -> BaseCoordinator {
        return commonFactory.makeMeetDetailCoordiantor(meetId: meetId)
    }
        
    /// 일정생성 플로우 생성
    func makePlanCreateFlowCoordinator(meetList: [MeetSummary],
                                       completionHandler: ((Plan) -> Void)?) -> BaseCoordinator {
        return commonFactory.makePlanCreateCoordinator(type: .create(meetList),
                                                       completionHandler: completionHandler)
    }
    
    /// 일정 상세 플로우 생성
    func makePlanDetailFlowCoordinator(postId: Int,
                                       type: PlanDetailType) -> BaseCoordinator {
        return commonFactory.makePlanDetailCoordinator(postId: postId, type: type)
    }
    
    func makeNotifyListFlowCoordinator() -> BaseCoordinator {
        let notifyListSceneDI = NotifyListSceneDIContainer(appNetworkService: appNetworkService,
                                                           commonFactory: commonFactory)
        return notifyListSceneDI.makeNotifyListCoordinator()
    }
}

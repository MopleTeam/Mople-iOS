//
//  NotifyListSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 4/11/25.
//

import Foundation

protocol NotifyListSceneDependencies {
    func makeNotifyListViewController(coordinator: NotifyListFlowCoordination) -> NotifyListViewController
    
    func makeMeetDefailtViewCoordinator(meetId: Int) -> BaseCoordinator
    func makePlanDetailFlowCoordinator(postId: Int,
                                       type: PlanDetailType) -> BaseCoordinator
    
}

final class NotifyListSceneDIContainer: NotifyListSceneDependencies {

    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
    }
    
    func makeNotifyListCoordinator() -> NotifyListFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
    }
}

extension NotifyListSceneDIContainer {

    // MARK: - 기본 뷰
    func makeNotifyListViewController(coordinator: NotifyListFlowCoordination) -> NotifyListViewController {
        return .init(title: "알림",
                     reactor: makeNotifyListViewReactor(coordinator: coordinator))
    }
    
    private func makeNotifyListViewReactor(coordinator: NotifyListFlowCoordination) -> NotifyListViewReactor {
        return .init(fetchNotifyList: makeFetchNotifyListUseCase(),
                     coordinator: coordinator)
    }
    
    private func makeFetchNotifyListUseCase() -> FetchNotifyList {
        let repo = DefaultNotifyRepo(networkService: appNetworkService)
        return FetchNotifyListUseCase(repo: repo)
    }
    
    // MARK: - 플로우 이동
    func makeMeetDefailtViewCoordinator(meetId: Int) -> BaseCoordinator {
        return commonFactory.makeMeetDetailCoordiantor(meetId: meetId)
    }
    
    func makePlanDetailFlowCoordinator(postId: Int, type: PlanDetailType) -> BaseCoordinator {
        return commonFactory.makePlanDetailCoordinator(postId: postId,
                                                       type: type)
    }
}

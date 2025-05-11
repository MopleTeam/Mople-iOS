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
                                       type: PostType) -> BaseCoordinator
    
}

final class NotifyListSceneDIContainer: BaseContainer, NotifyListSceneDependencies {
    
    func makeNotifyListCoordinator() -> NotifyListFlowCoordinator {
        return .init(dependencies: self,
                     navigationController: AppNaviViewController())
    }
}

extension NotifyListSceneDIContainer {

    // MARK: - Default View
    func makeNotifyListViewController(coordinator: NotifyListFlowCoordination) -> NotifyListViewController {
        return .init(screenName: .notification,
                     title: L10n.notifylist,
                     reactor: makeNotifyListViewReactor(coordinator: coordinator))
    }
    
    private func makeNotifyListViewReactor(coordinator: NotifyListFlowCoordination) -> NotifyListViewReactor {
        return .init(fetchNotifyList: makeFetchNotifyListUseCase(),
                     resetNotifyCount: makeResetNotifyCountUseCase(),
                     coordinator: coordinator)
    }
    
    private func makeFetchNotifyListUseCase() -> FetchNotifyList {
        let repo = DefaultNotifyRepo(networkService: appNetworkService)
        return FetchNotifyListUseCase(repo: repo)
    }
    
    private func makeResetNotifyCountUseCase() -> ResetNotifyCount {
        let repo = DefaultNotifyRepo(networkService: appNetworkService)
        return ResetNotifyCountUseCase(repo: repo)
    }
    
    // MARK: - Flow
    func makeMeetDefailtViewCoordinator(meetId: Int) -> BaseCoordinator {
        let meetDetailDI = MeetDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonFactory,
                                                      meetId: meetId,
                                                      isJoin: false)
        return meetDetailDI.makeMeetDetailCoordinator()
    }
    
    func makePlanDetailFlowCoordinator(postId: Int, type: PostType) -> BaseCoordinator {
        let planDetailDI = PostDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonFactory,
                                                      type: type,
                                                      id: postId)
        return planDetailDI.makePostDetailCoordinator()
    }
}

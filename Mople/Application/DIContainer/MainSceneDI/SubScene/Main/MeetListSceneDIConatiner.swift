//
//  MeetListSceneDIConatiner.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import UIKit

protocol MeetListSceneDependencies {
    // MARK: - View
    func makeMeetListViewController(coordinator: MeetListFlowCoordination) -> MeetListViewController
    func makeCreateMeetViewController(navigator: NavigationCloseable) -> CreateMeetViewController
    
    // MARK: - Flow
    func makeMeetDetailFlowCoordiantor(meetId: Int) -> BaseCoordinator
}

final class MeetListSceneDIConatiner {
    
    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory

    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
    }
    
    func makeMeetListFlowCoordinator() -> MeetListFlowCoordinator {
        let navi = AppNaviViewController()
        navi.tabBarItem = .init(title: TextStyle.Tabbar.group,
                                image: .people,
                                selectedImage: nil)
        return .init(navigationController: navi,
                     dependency: self)
    }
}

extension MeetListSceneDIConatiner: MeetListSceneDependencies {
    
    // MARK: - 모임 리스트
    func makeMeetListViewController(coordinator: MeetListFlowCoordination) -> MeetListViewController {
        return MeetListViewController(title: TextStyle.Tabbar.group,
                                      reactor: makeMeetListViewReactor(coordinator: coordinator))
    }
    
    private func makeMeetListViewReactor(coordinator: MeetListFlowCoordination) -> MeetListViewReactor {
        return MeetListViewReactor(fetchUseCase: makeMeetListUseCase(), // FetchGroupListMock()
                                    coordinator: coordinator)
    }
    
    private func makeMeetListUseCase() -> FetchMeetList {
        return FetchMeetListUseCase(meetListRepo: makeMeetListRepo())
    }
    
    private func makeMeetListRepo() -> MeetListRepo {
        return DefaultMeetListRepo(networkService: appNetworkService)
    }
    
    
    // MARK: - 모임 상세
    func makeMeetDetailFlowCoordiantor(meetId: Int) -> BaseCoordinator {
        let meetDetailDI = MeetDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonFactory,
                                                      meetId: meetId)
        return meetDetailDI.makeMeetDetailCoordinator()
    }
    
    func makeCreateMeetViewController(navigator: NavigationCloseable) -> CreateMeetViewController {
        return commonFactory.makeCreateMeetViewController(navigator: navigator)
    }
}

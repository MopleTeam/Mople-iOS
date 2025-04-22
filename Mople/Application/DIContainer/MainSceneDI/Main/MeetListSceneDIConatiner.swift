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
    func makeCreateMeetViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController
    
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
        let navi = AppNaviViewController(type: .main)
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
        let repo = DefaultMeetRepo(networkService: appNetworkService)
        return FetchMeetListUseCase(repo: repo)
    }
    
    
    // MARK: - 모임 상세
    func makeMeetDetailFlowCoordiantor(meetId: Int) -> BaseCoordinator {
        return commonFactory.makeMeetDetailCoordiantor(meetId: meetId)
    }
    
    // MARK: - 모임 생성 뷰컨트롤러
    func makeCreateMeetViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return commonFactory.makeCreateMeetViewController(isFlow: false,
                                                          isEdit: false,
                                                          type: .create,
                                                          coordinator: coordinator)
    }
}

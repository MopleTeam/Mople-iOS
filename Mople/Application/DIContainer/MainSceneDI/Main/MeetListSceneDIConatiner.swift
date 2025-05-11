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
    func makeMeetDetailFlowCoordiantor(meetId: Int,
                                       isJoin: Bool) -> BaseCoordinator
}

final class MeetListSceneDIConatiner: BaseContainer {
    func makeMeetListFlowCoordinator() -> MeetListFlowCoordinator {
        let navi = AppNaviViewController(type: .main)
        navi.tabBarItem = .init(title: L10n.meetlist,
                                image: .people,
                                selectedImage: nil)
        return .init(navigationController: navi,
                     dependency: self)
    }
}

// MARK: - Default View
extension MeetListSceneDIConatiner: MeetListSceneDependencies {
    
    func makeMeetListViewController(coordinator: MeetListFlowCoordination) -> MeetListViewController {
        return MeetListViewController(screenName: .meet_list,
                                      title: L10n.meetlist,
                                      reactor: makeMeetListViewReactor(coordinator: coordinator))
    }
    
    private func makeMeetListViewReactor(coordinator: MeetListFlowCoordination) -> MeetListViewReactor {
        return MeetListViewReactor(fetchUseCase: makeMeetListUseCase(), 
                                    coordinator: coordinator)
    }
    
    private func makeMeetListUseCase() -> FetchMeetList {
        let repo = DefaultMeetRepo(networkService: appNetworkService)
        return FetchMeetListUseCase(repo: repo)
    }
}

// MARK: - View
extension MeetListSceneDIConatiner {
    
    // MARK: - 모임 생성
    func makeCreateMeetViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return commonFactory.makeCreateMeetViewController(isFlow: false,
                                                          isEdit: false,
                                                          type: .create,
                                                          coordinator: coordinator)
    }
}

// MARK: - Flow
extension MeetListSceneDIConatiner {
    
    // MARK: - 모임 상세 
    func makeMeetDetailFlowCoordiantor(meetId: Int,
                                       isJoin: Bool) -> BaseCoordinator {
        let meetDetailDI = MeetDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonFactory,
                                                      meetId: meetId,
                                                      isJoin: isJoin)
        return meetDetailDI.makeMeetDetailCoordinator()
    }
}

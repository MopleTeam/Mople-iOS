//
//  MeetListFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import UIKit

protocol MeetListFlowCoordination {
    func presentMeetCreateView()
    func presentMeetDetailView(meetId: Int)
}

final class MeetListFlowCoordinator: BaseCoordinator, MeetListFlowCoordination {
    
    let dependency: MeetListSceneDependencies
    
    init(navigationController: AppNaviViewController,
         dependency: MeetListSceneDependencies) {
        self.dependency = dependency
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let meetListVC = dependency.makeMeetListViewController(coordinator: self)
        self.navigationController.pushViewController(meetListVC, animated: false)
    }
    
    override func dismiss() {
        self.navigationController.dismiss(animated: true)
    }
}

// MARK: - Flow Navigation (Present/Dismiss)
extension MeetListFlowCoordinator{
    func presentMeetCreateView() {
        let meetCreateVC = dependency.makeCreateMeetViewController(navigator: self)
        self.navigationController.presentWithTransition(meetCreateVC)
    }
    
    func presentMeetDetailView(meetId: Int) {
        let meetDetailFlowCoordinator = dependency.makeMeetDetailFlowCoordiantor(meetId: meetId)
        self.start(coordinator: meetDetailFlowCoordinator)
        self.navigationController.presentWithTransition(meetDetailFlowCoordinator.navigationController)
    }
}

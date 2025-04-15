//
//  MeetListFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import UIKit

protocol MeetListFlowCoordination: AnyObject {
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
}

// MARK: - View
extension MeetListFlowCoordinator: MeetCreateViewCoordination {
    func completed(with meet: Meet) {
        
    }
    
    func presentMeetCreateView() {
        let meetCreateVC = dependency.makeCreateMeetViewController(coordinator: self)
        self.navigationController.presentWithTransition(meetCreateVC)
    }
}

// MARK: - Flow
extension MeetListFlowCoordinator{
    func presentMeetDetailView(meetId: Int) {
        let meetDetailFlowCoordinator = dependency.makeMeetDetailFlowCoordiantor(meetId: meetId)
        self.start(coordinator: meetDetailFlowCoordinator)
        self.navigationController.presentWithTransition(meetDetailFlowCoordinator.navigationController)
    }
}

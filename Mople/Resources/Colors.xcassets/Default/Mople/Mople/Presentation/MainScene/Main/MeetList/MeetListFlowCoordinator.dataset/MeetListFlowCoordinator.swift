//
//  MeetListFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import UIKit

protocol MeetListFlowCoordination: AnyObject {
    func presentMeetCreateView()
    func presentMeetDetailView(meetId: Int, isJoin: Bool)
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
        self.push(meetListVC, animated: false)
    }
}

// MARK: - View
extension MeetListFlowCoordinator: MeetCreateViewCoordination {
    func presentMeetCreateView() {
        let meetCreateVC = dependency.makeCreateMeetViewController(coordinator: self)
        self.slidePresentWithTracking(meetCreateVC)
    }
    
    func completed(with meet: Meet) {
        self.dismiss(completion: { [weak self] in
            guard let meetId = meet.meetSummary?.id else { return }
            self?.presentMeetDetailView(meetId: meetId, isJoin: false)
        })
    }
}

// MARK: - Flow
extension MeetListFlowCoordinator{
    func presentMeetDetailView(meetId: Int,
                               isJoin: Bool) {
        let meetDetailFlowCoordinator = dependency.makeMeetDetailFlowCoordiantor(meetId: meetId,
                                                                                 isJoin: isJoin)
        self.start(coordinator: meetDetailFlowCoordinator)
        self.present(meetDetailFlowCoordinator.navigationController)
    }
}

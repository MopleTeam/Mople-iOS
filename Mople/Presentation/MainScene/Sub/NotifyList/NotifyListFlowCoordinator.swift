//
//  NotifyListFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 4/11/25.
//

import UIKit

protocol NotifyListFlowCoordination: AnyObject {
    func presentMeetDetailView(meetId: Int)
    func presentPlanDetailView(postId: Int, type: PlanDetailType)
    func endFlow()
}

final class NotifyListFlowCoordinator: BaseCoordinator, NotifyListFlowCoordination {
    
    private let dependencies: NotifyListSceneDependencies
    
    init(dependencies: NotifyListSceneDependencies,
         navigationController: AppNaviViewController) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let notifyListVC = dependencies.makeNotifyListViewController(coordinator: self)
        self.navigationController.pushViewController(notifyListVC, animated: false)
    }
}

// MARK: - Flow
extension NotifyListFlowCoordinator {
    
    // 모임상세 플로우
    func presentMeetDetailView(meetId: Int) {
        let meetDetailFlowCoordinator = dependencies.makeMeetDefailtViewCoordinator(meetId: meetId)
        start(coordinator: meetDetailFlowCoordinator)
        navigationController.presentWithTransition(meetDetailFlowCoordinator.navigationController)
    }
    
    // 일정 & 리뷰 플로우
    func presentPlanDetailView(postId: Int, type: PlanDetailType) {
        let planDetailFlowCoordinator = dependencies.makePlanDetailFlowCoordinator(postId: postId,
                                                                                   type: type)
        start(coordinator: planDetailFlowCoordinator)
        navigationController.presentWithTransition(planDetailFlowCoordinator.navigationController)
    }
}

// MARK: - End Flow
extension NotifyListFlowCoordinator {
    func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}

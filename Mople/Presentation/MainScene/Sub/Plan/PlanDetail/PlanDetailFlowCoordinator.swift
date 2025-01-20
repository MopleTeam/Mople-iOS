//
//  PlanDetailFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

protocol PlanDetailCoordination: AnyObject {
    func endFlow()
}

final class PlanDetailFlowCoordinator: BaseCoordinator {
    
    private let dependencies: PlanDetailSceneDependencies
    
    init(dependencies: PlanDetailSceneDependencies,
         navigationController: AppNaviViewController) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let planDetailVC = makePlanDetailViewController()
        navigationController.pushViewController(planDetailVC, animated: false)
    }
}

extension PlanDetailFlowCoordinator {
    private func makePlanDetailViewController() -> PlanDetailViewController {
        let planDetailVC = dependencies.makePlanDetailViewController()
        let commentListContainer = planDetailVC.commentContainer
        self.addCommentListView(parentVC: planDetailVC, container: commentListContainer)
        return planDetailVC
    }
    
    private func addCommentListView(parentVC: UIViewController, container: UIView) {
        let commentListVC = dependencies.makeCommentListViewController()
        parentVC.add(child: commentListVC, container: container)
    }
}

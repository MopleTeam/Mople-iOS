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
    private let planType: PlanDetailType
    
    init(dependencies: PlanDetailSceneDependencies,
         navigationController: AppNaviViewController,
         type: PlanDetailType) {
        self.dependencies = dependencies
        self.planType = type
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }
    
    override func start() {
        let planDetailVC = makePlanDetailViewController()
        navigationController.pushViewController(planDetailVC, animated: false)
    }
    
    private func setDismissGestureCompletion() {
        self.navigationController.setupTransitionCompletion(transitionType: .dismiss) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}

extension PlanDetailFlowCoordinator {
    private func makePlanDetailViewController() -> PlanDetailViewController {
        let planDetailVC = dependencies.makePlanDetailViewController(type: planType,
                                                                     coordinator: self)
        let commentListContainer = planDetailVC.commentContainer
        self.addCommentListView(parentVC: planDetailVC, container: commentListContainer)
        return planDetailVC
    }
    
    private func addCommentListView(parentVC: PlanDetailViewController, container: UIView) {
        let commentListVC = dependencies.makeCommentListViewController()
        parentVC.commentListView = commentListVC
        parentVC.add(child: commentListVC, container: container)
    }
}

extension PlanDetailFlowCoordinator: PlanDetailCoordination {
    func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}

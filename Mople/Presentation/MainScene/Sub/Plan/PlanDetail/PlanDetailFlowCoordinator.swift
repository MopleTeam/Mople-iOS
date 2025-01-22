//
//  PlanDetailFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

protocol PlanDetailCoordination: AnyObject {
    func showPhotoView(imagePaths: [String])
    func endFlow()
}

final class PlanDetailFlowCoordinator: BaseCoordinator {
    
    private let dependencies: PlanDetailSceneDependencies
    private let planType: PlanDetailType
    private var planDetailVC: PlanDetailViewController?
    
    init(dependencies: PlanDetailSceneDependencies,
         navigationController: AppNaviViewController,
         type: PlanDetailType) {
        print(#function, #line, "Path : # 55 :\(type) ")
        self.dependencies = dependencies
        self.planType = type
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        planDetailVC = makePlanDetailViewController()
        navigationController.pushViewController(planDetailVC!, animated: false)
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
    
    private func addCommentListView(parentVC: UIViewController, container: UIView) {
        let commentListVC = dependencies.makeCommentListViewController()
        parentVC.add(child: commentListVC, container: container)
    }
}

extension PlanDetailFlowCoordinator: PlanDetailCoordination {
    func showPhotoView(imagePaths: [String]) {
        guard let planDetailVC else { return }
        let photoListVC = dependencies.makePhotoListViewController(imagePaths: imagePaths)
        let photoContainer = planDetailVC.photoContainer
        planDetailVC.showPhotoView()
        planDetailVC.add(child: photoListVC, container: photoContainer)
    }
    
    func endFlow() {
        
    }
    
    
}

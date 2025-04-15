//
//  ReviewEditFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 2/6/25.
//

import Foundation

protocol ReviewEditViewCoordination: AnyObject {
    func pushMemberListView()
    func endFlow()
}

final class ReviewEditFlowCoordinator: BaseCoordinator, ReviewEditViewCoordination {
    
    private let dependencies: ReviewEditSceneDependencies
    
    init(dependencies: ReviewEditSceneDependencies,
         navigationController: AppNaviViewController) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }
    
    override func start() {
        let reviewEditView = dependencies.makePlanDetailViewController(coordinator: self)
        navigationController.pushViewController(reviewEditView, animated: false)
    }
}

// MARK: - MemberList View
extension ReviewEditFlowCoordinator: MemberListViewCoordination {
    func pushMemberListView() {
        let view = dependencies.makeMemberListViewController(coordinator: self)
        navigationController.pushViewController(view, animated: true)
    }
}

// MARK: - End Flow
extension ReviewEditFlowCoordinator {
    func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}
